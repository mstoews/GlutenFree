import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var saved: SavedStore

    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("探す", systemImage: "magnifyingglass") }

            SavedView()
                .tabItem { Label("お気に入り", systemImage: "heart") }
                .badge(saved.count)

            AccountView()
                .tabItem { Label("アカウント", systemImage: "person") }
        }
        .tint(Theme.brand)
    }
}
