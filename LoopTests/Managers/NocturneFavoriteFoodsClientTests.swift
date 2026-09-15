import XCTest
import LoopKit
@testable import Loop

final class NocturneFavoriteFoodsClientTests: XCTestCase {
    private struct FakeCredentialsProvider: NocturneCredentialsProviding {
        let result: Result<(baseURL: URL, apiToken: String), Error>
        func getNocturneCredentials() throws -> (baseURL: URL, apiToken: String) {
            try result.get()
        }
    }

    private final class FakeURLSession: NocturneURLSessionProtocol {
        private(set) var lastRequest: URLRequest?
        private let data: Data
        private let response: URLResponse

        init(data: Data, response: URLResponse) {
            self.data = data
            self.response = response
        }

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            lastRequest = request
            return (data, response)
        }
    }

    private struct DummyError: Error {}

    func testFetchFavoritesDecodesSuccessResponseAndSendsAuthHeader() async throws {
        let json = """
        [
          {
            "_id": "abc123",
            "type": "food",
            "category": "Breakfast",
            "subcategory": "",
            "name": "Oatmeal",
            "portion": 1,
            "carbs": 27,
            "fat": 3,
            "protein": 5,
            "energy": 620,
            "gi": 2,
            "unit": "g"
          }
        ]
        """.data(using: .utf8)!
        let baseURL = URL(string: "https://nocturne.example.com")!
        let response = HTTPURLResponse(url: baseURL.appendingPathComponent("api/v4/foods/favorites"), statusCode: 200, httpVersion: nil, headerFields: nil)!
        let session = FakeURLSession(data: json, response: response)
        let credentialsProvider = FakeCredentialsProvider(result: .success((baseURL: baseURL, apiToken: "noc_test")))
        let client = NocturneFavoriteFoodsClient(credentialsProvider: credentialsProvider, urlSession: session)

        let favorites = try await client.fetchFavorites()

        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites[0].name, "Oatmeal")
        XCTAssertEqual(session.lastRequest?.value(forHTTPHeaderField: "api-secret"), "noc_test")
        XCTAssertEqual(session.lastRequest?.url?.absoluteString, "https://nocturne.example.com/api/v4/foods/favorites")
    }

    func testFetchFavoritesThrowsMissingCredentialsWhenUnconfigured() async throws {
        let credentialsProvider = FakeCredentialsProvider(result: .failure(DummyError()))
        let session = FakeURLSession(data: Data(), response: URLResponse())
        let client = NocturneFavoriteFoodsClient(credentialsProvider: credentialsProvider, urlSession: session)

        do {
            _ = try await client.fetchFavorites()
            XCTFail("Expected missingCredentials error")
        } catch NocturneFavoriteFoodsClientError.missingCredentials {
            // expected
        }
    }

    func testFetchFavoritesThrowsUnauthorizedOn401() async throws {
        let baseURL = URL(string: "https://nocturne.example.com")!
        let response = HTTPURLResponse(url: baseURL.appendingPathComponent("api/v4/foods/favorites"), statusCode: 401, httpVersion: nil, headerFields: nil)!
        let session = FakeURLSession(data: Data(), response: response)
        let credentialsProvider = FakeCredentialsProvider(result: .success((baseURL: baseURL, apiToken: "bad-token")))
        let client = NocturneFavoriteFoodsClient(credentialsProvider: credentialsProvider, urlSession: session)

        do {
            _ = try await client.fetchFavorites()
            XCTFail("Expected unauthorized error")
        } catch NocturneFavoriteFoodsClientError.unauthorized {
            // expected
        }
    }

    func testFetchFavoritesThrowsServerErrorOn500() async throws {
        let baseURL = URL(string: "https://nocturne.example.com")!
        let response = HTTPURLResponse(url: baseURL.appendingPathComponent("api/v4/foods/favorites"), statusCode: 500, httpVersion: nil, headerFields: nil)!
        let session = FakeURLSession(data: Data(), response: response)
        let credentialsProvider = FakeCredentialsProvider(result: .success((baseURL: baseURL, apiToken: "noc_test")))
        let client = NocturneFavoriteFoodsClient(credentialsProvider: credentialsProvider, urlSession: session)

        do {
            _ = try await client.fetchFavorites()
            XCTFail("Expected serverError")
        } catch NocturneFavoriteFoodsClientError.serverError(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        }
    }
}
