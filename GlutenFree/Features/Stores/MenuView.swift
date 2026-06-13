import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var session: SessionStore
    let storeID: String
    let storeName: String

    @StateObject private var vm = MenuViewModel()
    @State private var showPaywall = false

    var body: some View {
        Group {
            if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.requiresSubscription {
                paywallPrompt
            } else if let error = vm.errorMessage {
                InfoStateView(systemImage: "exclamationmark.triangle", title: "Couldn’t load menu",
                              message: error, actionTitle: "Try again") {
                    Task { await vm.reload(storeID: storeID) }
                }
            } else if vm.items.isEmpty {
                InfoStateView(systemImage: "menucard", title: "No menu items yet")
            } else {
                List(vm.items) { MenuItemRow(item: $0) }
                    .listStyle(.plain)
            }
        }
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load(api: session.api, storeID: storeID) }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onSubscribed: { Task { await vm.reload(storeID: storeID) } })
        }
    }

    private var paywallPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Subscribe to view this menu")
                .font(.headline)
            Text("See verified gluten-free dishes, prices, and notes for \(storeName).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("See plans") { showPaywall = true }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let urlString = item.imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.secondarySystemBackground)
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name).font(.headline)
                    Spacer()
                    Text(Formatters.yen(item.priceYen)).font(.subheadline.bold())
                }
                GFStatusBadge(status: item.status)
                if let note = item.gfNote, !note.isEmpty {
                    Text(note).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct GFStatusBadge: View {
    let status: GFStatus

    private var color: Color {
        switch status {
        case .certified: return .green
        case .onRequest: return .orange
        case .containsHiddenGluten: return .red
        }
    }

    var body: some View {
        Text(status.label)
            .font(.caption2.bold())
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
