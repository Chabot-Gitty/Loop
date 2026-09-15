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

    init(client: NocturneFavoriteFoodsClientProtocol = NocturneFavoriteFoodsClient()) {
        self.client = client
    }

    func refresh() async {
        state = .loading

        do {
            let favorites = try await client.fetchFavorites()
            // Quickpicks are out of scope for this POC's display.
            state = .loaded(favorites.filter { $0.type == "food" })
        } catch NocturneFavoriteFoodsClientError.missingCredentials {
            state = .notConfigured
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
        case NocturneFavoriteFoodsClientError.decodingFailed(let details):
            return "Nocturne's response didn't match the expected format (\(details))."
        default:
            return "Couldn't reach Nocturne."
        }
    }
}
