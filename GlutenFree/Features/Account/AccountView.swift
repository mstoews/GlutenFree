import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Environment(\.openURL) private var openURL
    @State private var showPaywall = false
    @State private var showComingSoon = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 16) {
                        profileCard
                        subscriptionCard
                        settingsCard
                        footer
                    }
                    .padding(.horizontal, Metrics.page)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .background(Theme.page)
            .navigationBarHidden(true)
            .navigationDestination(for: AccountRoute.self) { _ in ProfileDetailView() }
            .task { await session.loadSubscription() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .alert("近日対応予定です。", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private enum AccountRoute: Hashable { case profile }

    // MARK: Header

    private var header: some View {
        Text("アカウント")
            .font(.system(size: 30, weight: .heavy)).tracking(-0.5).foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Metrics.page)
            .padding(.top, 8).padding(.bottom, 8)
            .background(Theme.page)
    }

    // MARK: Profile

    private var email: String { session.user?.email ?? "" }

    private var displayName: String {
        let local = email.split(separator: "@").first.map(String.init) ?? email
        return local.isEmpty ? "ゲスト" : local.prefix(1).uppercased() + local.dropFirst()
    }

    private var initial: String { String(email.first ?? "G").uppercased() }

    private var profileCard: some View {
        NavigationLink(value: AccountRoute.profile) {
            HStack(spacing: 14) {
                Text(initial)
                    .font(.system(size: 22, weight: .heavy)).foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Theme.brand).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName).font(.system(size: 16, weight: .bold)).foregroundStyle(Theme.ink)
                    Text(email.isEmpty ? "—" : email).font(.system(size: 13)).foregroundStyle(Theme.sub)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.hint)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: Subscription

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles").font(.system(size: 12, weight: .bold))
                    Text("Gurufuri+").font(.system(size: 15, weight: .heavy))
                }
                .foregroundStyle(.white)
                Spacer()
                Text(session.isSubscribed ? "メンバー" : "未加入")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.18)).clipShape(Capsule())
            }

            Text(session.isSubscribed
                 ? "全店舗の詳細とメニューが見放題です。"
                 : "メニューはメンバー限定です。アップグレードで全店舗を解放。")
                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center) {
                subscriptionFootnote
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.9))
                Spacer()
                if !session.isSubscribed {
                    Button { showPaywall = true } label: {
                        Text("アップグレード")
                            .font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.brand700)
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(.white).clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Theme.brand600, Theme.brand800],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var subscriptionFootnote: Text {
        if session.isSubscribed {
            if let renews = Formatters.date(session.subscription?.subExpiresAt) {
                return Text("次回更新 \(renews)")
            }
            return Text("ご利用中")
        }
        return Text("月額 ¥480 から")
    }

    // MARK: Settings

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingRow(icon: "leaf", title: "食事制限の設定") { showComingSoon = true }
            rowDivider
            settingRow(icon: "bubble.left", title: "お問い合わせ") {
                open("mailto:support@gurufuri.app")
            }
            rowDivider
            settingRow(icon: "exclamationmark.triangle", title: "店舗の情報を報告") {
                open("mailto:support@gurufuri.app?subject=店舗情報の報告")
            }
            rowDivider
            settingRow(icon: "info.circle", title: "利用規約とプライバシー") {
                open("https://gurufuri.app/legal")
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
    }

    private func settingRow(icon: String, title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 15)).foregroundStyle(Theme.brand).frame(width: 22)
                Text(title).font(.system(size: 15)).foregroundStyle(Theme.ink)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.hint)
            }
            .padding(.horizontal, 14).padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var rowDivider: some View {
        Divider().overlay(Theme.separator).padding(.leading, 48)
    }

    private var footer: some View {
        Text("Noble Ledger · Gurufuri v0.0.4.66")
            .font(.system(size: 11)).foregroundStyle(Theme.hint)
            .padding(.top, 4)
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) { openURL(url) }
    }
}

// MARK: - Profile detail

private struct ProfileDetailView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.page.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Divider().overlay(Theme.separator)
                ScrollView {
                    VStack(spacing: 16) {
                        infoCard
                        Button("サインアウト", role: .destructive) {
                            session.logout()
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .bold)).foregroundStyle(Theme.systemRed)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.separator, lineWidth: 0.5))
                    }
                    .padding(.horizontal, Metrics.page)
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.brand)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            Text("アカウント詳細").font(.system(size: 17, weight: .bold)).foregroundStyle(Theme.ink)
            Spacer()
        }
        .padding(.horizontal, Metrics.page).padding(.top, 6).padding(.bottom, 10)
        .background(Theme.page)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(label: "メール", value: Text(verbatim: session.user?.email ?? "—"))
            rowDivider
            infoRow(label: "ステータス",
                    value: Text(session.isSubscribed ? "メンバー（Gurufuri+）" : "無料プラン"))
            if let renews = Formatters.date(session.subscription?.subExpiresAt) {
                rowDivider
                infoRow(label: session.isSubscribed ? "次回更新" : "有効期限", value: Text(verbatim: renews))
            }
            rowDivider
            Button { Task { await subscriptions.restore() } } label: {
                HStack {
                    Text("購入を復元").font(.system(size: 15)).foregroundStyle(Theme.brand)
                    Spacer()
                }
                .padding(.horizontal, 14).padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.separator, lineWidth: 0.5))
    }

    private func infoRow(label: LocalizedStringKey, value: Text) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundStyle(Theme.sub)
            Spacer()
            value.font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
    }

    private var rowDivider: some View {
        Divider().overlay(Theme.separator).padding(.leading, 14)
    }
}
