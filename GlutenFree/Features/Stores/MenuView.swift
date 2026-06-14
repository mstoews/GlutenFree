import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    let storeID: String
    let storeName: String

    @StateObject private var vm = MenuViewModel()
    @State private var showPaywall = false

    private var sortedItems: [MenuItem] {
        vm.items.sorted { a, b in
            let pa = Self.priority(a.status), pb = Self.priority(b.status)
            return pa != pb ? pa < pb : a.sortOrder < b.sortOrder
        }
    }

    private static func priority(_ status: GFStatus) -> Int {
        switch status {
        case .certified: return 0
        case .onRequest: return 1
        case .containsHiddenGluten: return 2
        }
    }

    var body: some View {
        ZStack {
            Theme.page.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().overlay(Theme.separator)
                content
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { await vm.load(api: session.api, storeID: storeID) }
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeName: storeName, onSubscribed: { Task { await vm.reload(storeID: storeID) } })
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.brand)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 1) {
                    Text(storeName).font(.system(size: 17, weight: .bold)).foregroundStyle(Theme.ink).lineLimit(1)
                    Text(subtitle).font(.system(size: 12)).foregroundStyle(Theme.sub)
                }
                Spacer(minLength: 0)
            }
            if !vm.items.isEmpty { legend }
        }
        .padding(.horizontal, Metrics.page)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Theme.page)
    }

    private var subtitle: String {
        vm.items.isEmpty ? "メニュー" : "メニュー・全\(vm.items.count)品"
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendDot(.certified)
            legendDot(.onRequest)
            legendDot(.containsHiddenGluten)
            Spacer(minLength: 0)
        }
    }

    private func legendDot(_ status: GFStatus) -> some View {
        HStack(spacing: 5) {
            Circle().fill(status.dotColor).frame(width: 7, height: 7)
            Text(status.labelJa).font(.system(size: 12)).foregroundStyle(Theme.sub)
        }
    }

    // MARK: Content

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.requiresSubscription {
            paywallPrompt
        } else if let error = vm.errorMessage {
            InfoStateView(systemImage: "exclamationmark.triangle", title: "メニューを読み込めませんでした",
                          message: error, actionTitle: "再試行") {
                Task { await vm.reload(storeID: storeID) }
            }
        } else if vm.items.isEmpty {
            InfoStateView(systemImage: "menucard", title: "メニューはまだありません")
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                        MenuItemRow(item: item)
                        if index < sortedItems.count - 1 {
                            Divider().overlay(Theme.separator).padding(.leading, 82)
                        }
                    }
                }
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
                .padding(.horizontal, Metrics.page)
                .padding(.top, 10)

                disclaimer
            }
        }
    }

    private var disclaimer: some View {
        Text("GF情報は店舗からの申告に基づき、内部審査を経て掲載しています。最終的なアレルギー対応は各店舗にご確認ください。")
            .font(.system(size: 11)).foregroundStyle(Theme.hint)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28).padding(.vertical, 18)
    }

    private var paywallPrompt: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 30)).foregroundStyle(Theme.brand)
                .frame(width: 84, height: 84).background(Theme.brandSoft).clipShape(Circle())
            Text("メニューはメンバー限定です").font(.system(size: 17, weight: .bold)).foregroundStyle(Theme.ink)
            Text("\(storeName)の認証済みメニューと注意点を見るにはご登録ください。")
                .font(.system(size: 14)).foregroundStyle(Theme.sub).multilineTextAlignment(.center)
            Button { showPaywall = true } label: {
                Text("プランを見る").font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Theme.brand).foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
    }
}

private struct MenuItemRow: View {
    let item: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            StorePhoto(url: item.imageUrl, width: 56, height: 56, cornerRadius: 12, seed: item.id.hashValue)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name).font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let note = item.gfNote, !note.isEmpty {
                    Text(note).font(.system(size: 12)).foregroundStyle(Theme.sub).lineLimit(2)
                }
                GFBadge(status: item.status, short: true)
            }
            Spacer(minLength: 8)
            Text(Formatters.yen(item.priceYen))
                .font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }
}
