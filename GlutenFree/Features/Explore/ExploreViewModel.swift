import Combine
import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var wards: [Ward] = []
    @Published var stores: [StoreCard] = []
    @Published var selectedWardID: Int?
    @Published var layout: StoreLayout = .rich
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    private var nextCursor: String?
    private var api: APIClient?
    private var didLoad = false

    var filteredStores: [StoreCard] {
        guard !searchText.isEmpty else { return stores }
        let q = searchText.lowercased()
        return stores.filter {
            $0.name.lowercased().contains(q)
            || $0.cuisine.lowercased().contains(q)
            || $0.ward.nameEn.lowercased().contains(q)
            || $0.ward.nameJa.contains(searchText)
        }
    }

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
