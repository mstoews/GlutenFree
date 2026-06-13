import Combine
import Foundation

@MainActor
final class StoreDetailViewModel: ObservableObject {
    @Published var detail: StoreDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(api: APIClient, id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            detail = try await api.storeDetail(id: id)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}
