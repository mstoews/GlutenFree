import Combine
import Foundation

@MainActor
final class StoresViewModel: ObservableObject {
    @Published var wards: [Ward] = []
    @Published var stores: [StoreCard] = []
    @Published var selectedWardID: Int?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published private(set) var tier = "free"

    private var nextCursor: String?
    private var api: APIClient?
    private var didLoad = false

    func start(api: APIClient) async {
        self.api = api
        guard !didLoad else { return }
        didLoad = true
        await loadWards()
        await reload()
    }

    func loadWards() async {
        guard let api else { return }
        wards = (try? await api.wards()) ?? []
    }

    func reload() async {
        guard let api else { return }
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await api.stores(wardID: selectedWardID, cursor: nil)
            tier = resp.tier
            stores = resp.stores
            nextCursor = resp.nextCursor
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            stores = []
            nextCursor = nil
        }
        isLoading = false
    }

    func selectWard(_ id: Int?) async {
        guard id != selectedWardID else { return }
        selectedWardID = id
        await reload()
    }

    func loadMoreIfNeeded(current item: StoreCard) async {
        guard let api, let cursor = nextCursor, !isLoadingMore,
              stores.last?.id == item.id else { return }
        isLoadingMore = true
        if let resp = try? await api.stores(wardID: selectedWardID, cursor: cursor) {
            stores.append(contentsOf: resp.stores)
            nextCursor = resp.nextCursor
        }
        isLoadingMore = false
    }
}
