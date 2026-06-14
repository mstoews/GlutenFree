import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var saved: SavedStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                if saved.stores.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(saved.stores) { card in
                                StoreCardView(store: card, layout: .list)
                                    .contentShape(Rectangle())
                                    .onTapGesture { path.append(card) }
                            }
                        }
                        .padding(.horizontal, Metrics.page)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Theme.page)
            .navigationBarHidden(true)
            .navigationDestination(for: StoreCard.self) { card in
                StoreDetailView(card: card)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("お気に入り").font(.system(size: 30, weight: .heavy)).tracking(-0.5).foregroundStyle(Theme.ink)
            Text("\(saved.count)件の保存済み店舗").font(.system(size: 13)).foregroundStyle(Theme.sub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Metrics.page)
        .padding(.top, 8).padding(.bottom, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 30))
                .foregroundStyle(Theme.hint)
                .frame(width: 84, height: 84)
                .background(Theme.card2)
                .clipShape(Circle())
            Text("まだ保存がありません").font(.system(size: 17, weight: .bold)).foregroundStyle(Theme.ink)
            Text("店舗のハートをタップすると、ここに集まります。")
                .font(.system(size: 14)).foregroundStyle(Theme.sub).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
