import Combine
import Foundation

/// Wishlist / saved stores, persisted to UserDefaults. Stores the full card so
/// the Saved tab can render without re-fetching.
@MainActor
final class SavedStore: ObservableObject {
    @Published private(set) var stores: [StoreCard] = []

    private let key = "gurufuri.saved.v1"

    init() { load() }

    var count: Int { stores.count }

    func isSaved(_ id: String) -> Bool { stores.contains { $0.id == id } }

    func toggle(_ store: StoreCard) {
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores.remove(at: index)
        } else {
            stores.insert(store, at: 0)
        }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([StoreCard].self, from: data) else { return }
        stores = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(stores) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
