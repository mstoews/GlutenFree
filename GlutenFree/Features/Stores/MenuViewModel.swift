import Combine
import Foundation

@MainActor
final class MenuViewModel: ObservableObject {
    @Published var items: [MenuItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var requiresSubscription = false

    private var api: APIClient?

    func load(api: APIClient, storeID: String) async {
        self.api = api
        isLoading = true
        errorMessage = nil
        requiresSubscription = false
        do {
            items = try await api.menu(storeID: storeID).items
        } catch let error as APIError where error.isPaymentRequired {
            requiresSubscription = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func reload(storeID: String) async {
        guard let api else { return }
        await load(api: api, storeID: storeID)
    }
}
