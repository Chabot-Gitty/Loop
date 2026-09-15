import XCTest
@testable import Loop

@MainActor
final class NocturneFavoritesSectionViewModelTests: XCTestCase {
    private struct FakeCredentialsProvider: NocturneCredentialsProviding {
        let result: Result<(baseURL: URL, apiToken: String), Error>
        func getNocturneCredentials() throws -> (baseURL: URL, apiToken: String) { try result.get() }
    }

    private final class FakeClient: NocturneFavoriteFoodsClientProtocol {
        var result: Result<[NocturneFavoriteFood], Error> = .success([])
        func fetchFavorites() async throws -> [NocturneFavoriteFood] { try result.get() }
    }

    private struct DummyError: Error {}

    private func makeFood(id: String, type: String, name: String, carbs: Double) -> NocturneFavoriteFood {
        NocturneFavoriteFood(id: id, type: type, category: "", subcategory: "", name: name, portion: 1, carbs: carbs, fat: 0, protein: 0, energy: 0, gi: 2, unit: "g")
    }

    func testRefreshWithoutCredentialsIsNotConfigured() async {
        let viewModel = NocturneFavoritesSectionViewModel(
            client: FakeClient(),
            credentialsProvider: FakeCredentialsProvider(result: .failure(DummyError()))
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.state, .notConfigured)
    }

    func testRefreshWithCredentialsLoadsFoodFilteredFavorites() async {
        let client = FakeClient()
        client.result = .success([
            makeFood(id: "1", type: "food", name: "Toast", carbs: 15),
            makeFood(id: "2", type: "quickpick", name: "Breakfast combo", carbs: 40)
        ])
        let viewModel = NocturneFavoritesSectionViewModel(
            client: client,
            credentialsProvider: FakeCredentialsProvider(result: .success((baseURL: URL(string: "https://nocturne.example.com")!, apiToken: "noc_test")))
        )

        await viewModel.refresh()

        XCTAssertEqual(viewModel.state, .loaded([makeFood(id: "1", type: "food", name: "Toast", carbs: 15)]))
    }

    func testRefreshOnClientErrorSetsErrorState() async {
        struct SomeError: Error {}
        let client = FakeClient()
        client.result = .failure(SomeError())
        let viewModel = NocturneFavoritesSectionViewModel(
            client: client,
            credentialsProvider: FakeCredentialsProvider(result: .success((baseURL: URL(string: "https://nocturne.example.com")!, apiToken: "noc_test")))
        )

        await viewModel.refresh()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state, got \(viewModel.state)")
        }
    }
}
