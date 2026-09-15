import Foundation
import LoopKit

protocol NocturneCredentialsProviding {
    func getNocturneCredentials() throws -> (baseURL: URL, apiToken: String)
}

private let NocturneAPIAccount = "NocturneAPI"

extension KeychainManager {
    func setNocturneCredentials(baseURL: URL? = nil, apiToken: String? = nil) throws {
        let credentials: InternetCredentials?
        if let baseURL, let apiToken {
            credentials = InternetCredentials(username: NocturneAPIAccount, password: apiToken, url: baseURL)
        } else {
            credentials = nil
        }
        try replaceInternetCredentials(credentials, forAccount: NocturneAPIAccount)
    }

    func getNocturneCredentials() throws -> (baseURL: URL, apiToken: String) {
        let credentials = try getInternetCredentials(account: NocturneAPIAccount)
        return (baseURL: credentials.url, apiToken: credentials.password)
    }
}

extension KeychainManager: NocturneCredentialsProviding {}

protocol NocturneURLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NocturneURLSessionProtocol {}

enum NocturneFavoriteFoodsClientError: Error, Equatable {
    case missingCredentials
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int)
    case decodingFailed(String)
}

protocol NocturneFavoriteFoodsClientProtocol {
    func fetchFavorites() async throws -> [NocturneFavoriteFood]
}

final class NocturneFavoriteFoodsClient: NocturneFavoriteFoodsClientProtocol {
    private let credentialsProvider: NocturneCredentialsProviding
    private let urlSession: NocturneURLSessionProtocol

    init(credentialsProvider: NocturneCredentialsProviding = KeychainManager(), urlSession: NocturneURLSessionProtocol = URLSession.shared) {
        self.credentialsProvider = credentialsProvider
        self.urlSession = urlSession
    }

    func fetchFavorites() async throws -> [NocturneFavoriteFood] {
        guard let credentials = try? credentialsProvider.getNocturneCredentials() else {
            throw NocturneFavoriteFoodsClientError.missingCredentials
        }

        let endpoint = credentials.baseURL.appendingPathComponent("api/v4/foods/favorites")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue(credentials.apiToken, forHTTPHeaderField: "api-secret")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NocturneFavoriteFoodsClientError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                return try JSONDecoder().decode([NocturneFavoriteFood].self, from: data)
            } catch {
                throw NocturneFavoriteFoodsClientError.decodingFailed(String(describing: error))
            }
        case 401, 403:
            throw NocturneFavoriteFoodsClientError.unauthorized
        default:
            throw NocturneFavoriteFoodsClientError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
