import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var saved: SavedStore
    // Persisted so a language switch (which rebuilds the tree) keeps the tab.
    @AppStorage("gf.selectedTab") private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            ExploreView()
                .tabItem { Label("探す", systemImage: "magnifyingglass") }
                .tag(0)

            SavedView()
                .tabItem { Label("お気に入り", systemImage: "heart") }
                .badge(saved.count)
                .tag(1)

            AccountView()
                .tabItem { Label("アカウント", systemImage: "person") }
                .tag(2)
        }
        .tint(Theme.brand)
    }
}
