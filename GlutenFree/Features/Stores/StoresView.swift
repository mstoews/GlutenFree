import SwiftUI

struct StoresView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm = StoresViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !vm.wards.isEmpty {
                    wardFilterBar
                    Divider()
                }
                content
            }
            .navigationTitle("Stores")
            .navigationDestination(for: StoreCard.self) { store in
                StoreDetailView(storeID: store.id, storeName: store.name)
            }
            .task { await vm.start(api: session.api) }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.stores.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage, vm.stores.isEmpty {
            InfoStateView(systemImage: "wifi.exclamationmark", title: "Couldn’t load stores",
                          message: error, actionTitle: "Try again") {
                Task { await vm.reload() }
            }
        } else if vm.stores.isEmpty {
            InfoStateView(systemImage: "fork.knife", title: "No stores yet",
                          message: "Check back soon for gluten-free spots in this area.")
        } else {
            List {
                ForEach(vm.stores) { store in
                    NavigationLink(value: store) {
                        StoreRow(store: store)
                    }
                    .task { await vm.loadMoreIfNeeded(current: store) }
                }
                if vm.isLoadingMore {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
            }
            .listStyle(.plain)
            .refreshable { await vm.reload() }
        }
    }

    private var wardFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                WardChip(title: "All", isSelected: vm.selectedWardID == nil) {
                    Task { await vm.selectWard(nil) }
                }
                ForEach(vm.wards) { ward in
                    WardChip(title: ward.nameEn, isSelected: vm.selectedWardID == ward.id) {
                        Task { await vm.selectWard(ward.id) }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct WardChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.green : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct StoreRow: View {
    let store: StoreCard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(store.name).font(.headline)
                if store.isGfOriented == true {
                    Text("GF")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            Text("\(store.ward.nameEn) · \(store.ward.nameJa)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let address = store.address {
                Text(address).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
