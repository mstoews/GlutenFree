import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            StoresView()
                .tabItem { Label("Stores", systemImage: "fork.knife") }

            AccountView()
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }
}
