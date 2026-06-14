import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm = ExploreViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                if !vm.wards.isEmpty {
                    WardChips(wards: vm.wards, selected: vm.selectedWardID) { id in
                        Task { await vm.selectWard(id) }
                    }
                    Divider().overlay(Theme.separator)
                }
                resultBar
                content
            }
            .background(Theme.page)
            .navigationBarHidden(true)
            .navigationDestination(for: StoreCard.self) { card in
                StoreDetailView(card: card)
            }
            .task { await vm.start(api: session.api) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("探す").font(.system(size: 30, weight: .heavy)).tracking(-0.5).foregroundStyle(Theme.ink)
                    Text("東京 · グルテンフリー対応").font(.system(size: 13)).foregroundStyle(Theme.sub)
                }
                Spacer()
                LayoutSwitcher(layout: $vm.layout)
            }
            searchField
        }
        .padding(.horizontal, Metrics.page)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Theme.page)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(Theme.hint)
            TextField("店名・エリアで検索", text: $vm.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !vm.searchText.isEmpty {
                Button { vm.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.hint)
                }
            }
        }
        .font(.system(size: 15))
        .padding(.horizontal, 12).padding(.vertical, 11)
        .background(Theme.card2)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var resultBar: some View {
        HStack {
            Text("\(vm.filteredStores.count)件")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.sub)
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "location.north.fill").font(.system(size: 10))
                Text("近い順").font(.system(size: 13))
            }
            .foregroundStyle(Theme.sub)
        }
        .padding(.horizontal, Metrics.page)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.stores.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage, vm.stores.isEmpty {
            InfoStateView(systemImage: "wifi.exclamationmark", title: "読み込めませんでした",
                          message: error, actionTitle: "再試行") {
                Task { await vm.reload() }
            }
        } else if vm.filteredStores.isEmpty {
            InfoStateView(systemImage: "fork.knife", title: "店舗が見つかりません")
        } else {
            ScrollView {
                if vm.layout == .grid {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        cards
                    }
                    .padding(.horizontal, Metrics.page)
                    .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: vm.layout == .rich ? 14 : 10) {
                        cards
                    }
                    .padding(.horizontal, Metrics.page)
                    .padding(.vertical, 8)
                }
                if vm.isLoadingMore { ProgressView().padding(.vertical, 8) }
            }
        }
    }

    private var cards: some View {
        ForEach(vm.filteredStores) { card in
            StoreCardView(store: card, layout: vm.layout)
                .contentShape(Rectangle())
                .onTapGesture { path.append(card) }
                .task { await vm.loadMoreIfNeeded(current: card) }
        }
    }
}
