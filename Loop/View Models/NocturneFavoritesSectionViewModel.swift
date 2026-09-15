import Foundation
import LoopKit

@MainActor
final class NocturneFavoritesSectionViewModel: ObservableObject {
    enum State: Equatable {
        case notConfigured
        case loading
        case loaded([NocturneFavoriteFood])
        case error(String)
    }

    @Published private(set) var state: State = .notConfigured

    private let client: NocturneFavoriteFoodsClientProtocol
    private let credentialsProvider: NocturneCredentialsProviding

    init(client: NocturneFavoriteFoodsClientProtocol = NocturneFavoriteFoodsClient(), credentialsProvider: NocturneCredentialsProviding = KeychainManager()) {
        self.client = client
        self.credentialsProvider = credentialsProvider
    }

    func refresh() async {
        guard (try? credentialsProvider.getNocturneCredentials()) != nil else {
            state = .notConfigured
            return
        }

        state = .loading

        do {
            let favorites = try await client.fetchFavorites()
            // Quickpicks are out of scope for this POC's display.
            state = .loaded(favorites.filter { $0.type == "food" })
        } catch {
            state = .error(message(for: error))
        }
    }

    private func message(for error: Error) -> String {
        switch error {
        case NocturneFavoriteFoodsClientError.unauthorized:
            return "Nocturne rejected the API token."
        case NocturneFavoriteFoodsClientError.serverError(let statusCode):
            return "Nocturne returned an error (\(statusCode))."
        case NocturneFavoriteFoodsClientError.invalidResponse:
            return "Nocturne returned an unexpected response."
        default:
            return "Couldn't reach Nocturne."
        }
    }
}
