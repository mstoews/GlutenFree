import SwiftUI

struct StoreDetailView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.openURL) private var openURL
    let storeID: String
    let storeName: String

    @StateObject private var vm = StoreDetailViewModel()
    @State private var showDirections = false

    var body: some View {
        Group {
            if let detail = vm.detail {
                detailList(detail)
            } else if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.errorMessage {
                InfoStateView(systemImage: "exclamationmark.triangle", title: "Couldn’t load store",
                              message: error, actionTitle: "Try again") {
                    Task { await vm.load(api: session.api, id: storeID) }
                }
            }
        }
        .navigationTitle(storeName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load(api: session.api, id: storeID) }
    }

    private func detailList(_ detail: StoreDetail) -> some View {
        List {
            Section {
                HStack {
                    Text(detail.name).font(.title3.bold())
                    Spacer()
                    if detail.isGfOriented {
                        Label("GF-oriented", systemImage: "leaf.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }
                Text("\(detail.ward.nameEn) · \(detail.ward.nameJa)")
                    .foregroundStyle(.secondary)
            }

            Section("Address") {
                Text(detail.address)
                Button {
                    showDirections = true
                } label: {
                    Label("Directions", systemImage: "map")
                }
                .confirmationDialog("Open in", isPresented: $showDirections, titleVisibility: .visible) {
                    Button("Apple Maps") { openMaps(detail, provider: .apple) }
                    Button("Google Maps") { openMaps(detail, provider: .google) }
                    Button("Cancel", role: .cancel) {}
                }
            }

            if !detail.openingHours.isEmpty {
                Section("Opening hours") {
                    ForEach(detail.openingHours) { hour in
                        HStack {
                            Text(Formatters.weekday(hour.day))
                            Spacer()
                            Text("\(Formatters.clock(hour.open)) – \(Formatters.clock(hour.close))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                NavigationLink {
                    MenuView(storeID: detail.id, storeName: detail.name)
                } label: {
                    Label("View GF menu", systemImage: "menucard")
                }
            }
        }
    }

    private enum MapProvider { case apple, google }

    private func openMaps(_ detail: StoreDetail, provider: MapProvider) {
        let lat = detail.latitude, lng = detail.longitude
        let name = detail.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url: URL?
        switch provider {
        case .apple:
            url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(name)")
        case .google:
            // App if installed, else web fallback.
            if let app = URL(string: "comgooglemaps://?q=\(lat),\(lng)"),
               UIApplication.shared.canOpenURL(app) {
                url = app
            } else {
                url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lng)")
            }
        }
        if let url { openURL(url) }
    }
}
