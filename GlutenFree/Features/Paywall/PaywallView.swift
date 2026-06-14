import SwiftUI
import StoreKit

/// Membership sheet. Shown when the user hits paid content (a 402) or taps the
/// "unlock menu" CTA. Presents the plan catalog, drives the StoreKit purchase,
/// and calls `onSubscribed` once the backend confirms an active subscription.
struct PaywallView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var storeName: String = ""
    var onSubscribed: () -> Void = {}

    @State private var selectedPlanID = AppConfig.annualProductID

    // Static catalog — prices match the JP storefront. Each plan binds to a
    // StoreKit product by id for the actual purchase.
    private struct Plan: Identifiable {
        let id: String
        let isAnnual: Bool
        let priceText: String   // verbatim price (currency), not localized
        let recommended: Bool
        let renewNote: String   // verbatim; interpolated into the localized fine-print

        var period: LocalizedStringKey { isAnnual ? "/年" : "/月" }
        var subText: LocalizedStringKey { isAnnual ? "¥317/月 相当・2か月分お得" : "いつでもキャンセル可能" }
        var ctaText: LocalizedStringKey { isAnnual ? "¥3,800/年で続ける" : "¥480/月で続ける" }
    }

    private let plans: [Plan] = [
        Plan(id: AppConfig.annualProductID, isAnnual: true, priceText: "¥3,800", recommended: true, renewNote: "¥3,800/年"),
        Plan(id: AppConfig.monthlyProductID, isAnnual: false, priceText: "¥480", recommended: false, renewNote: "¥480/月"),
    ]

    private var selectedPlan: Plan { plans.first { $0.id == selectedPlanID } ?? plans[0] }

    private let features = [
        "全店舗の詳細とメニューを閲覧",
        "品目ごとのGFステータスと注意点",
        "区・エリアで絞り込み（路線は近日）",
        "お気に入りを無制限に保存",
    ]

    var body: some View {
        ZStack {
            Theme.page.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 18) {
                        featureList
                        VStack(spacing: 10) { ForEach(plans) { planCard($0) } }
                        finePrint
                        if let error = subscriptions.errorMessage {
                            Text(error).font(.system(size: 12)).foregroundStyle(Theme.systemRed)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, Metrics.page)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { ctaBar }
        .task { await subscriptions.loadProducts() }
        .overlay {
            if subscriptions.isPurchasing {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView().controlSize(.large)
                }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: [Theme.brand600, Theme.brand800],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { geo in
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .position(x: geo.size.width - 8, y: 28)
            }
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles").font(.system(size: 11, weight: .bold))
                    Text("Gurufuri+").font(.system(size: 13, weight: .heavy))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.white.opacity(0.18))
                .clipShape(Capsule())

                Text("全メニューを、解放しよう。")
                    .font(.system(size: 25, weight: .heavy)).tracking(-0.5)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.18)).clipShape(Circle())
            }
            .padding(.top, 14).padding(.trailing, 14)
        }
        .frame(height: 200)
        .clipped()
    }

    private var subtitle: String {
        storeName.isEmpty
            ? "全店舗の詳細とメニューが見放題に。"
            : "「\(storeName)」を含む全店舗の詳細とメニューが見放題に。"
    }

    // MARK: Features

    private var featureList: some View {
        VStack(spacing: 14) {
            ForEach(features, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 22, height: 22).background(Theme.brand).clipShape(Circle())
                    Text(feature).font(.system(size: 14)).foregroundStyle(Theme.ink)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: Plan cards

    private func planCard(_ plan: Plan) -> some View {
        let selected = plan.id == selectedPlanID
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(selected ? Theme.brand : Theme.separator, lineWidth: 2)
                    .frame(width: 22, height: 22)
                if selected {
                    Circle().fill(Theme.brand).frame(width: 22, height: 22)
                    Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(verbatim: plan.priceText).font(.system(size: 20, weight: .heavy)).foregroundStyle(Theme.ink)
                    Text(plan.period).font(.system(size: 13)).foregroundStyle(Theme.sub)
                }
                Text(plan.subText).font(.system(size: 12)).foregroundStyle(Theme.sub)
            }
            Spacer(minLength: 0)
            if plan.recommended {
                Text("おすすめ")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Theme.brand).clipShape(Capsule())
            }
        }
        .padding(14)
        .background(selected ? Theme.brandSoft : Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(selected ? Theme.brand : Theme.separator, lineWidth: selected ? 2 : 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { selectedPlanID = plan.id }
    }

    private var finePrint: some View {
        Text("\(selectedPlan.renewNote)で自動更新。確認後にApple IDに課金されます。設定からいつでもキャンセルできます。")
            .font(.system(size: 11)).foregroundStyle(Theme.hint)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    // MARK: CTA bar

    private var ctaBar: some View {
        VStack(spacing: 12) {
            Divider().overlay(Theme.separator)
            Button(action: purchaseSelected) {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo").font(.system(size: 15, weight: .semibold))
                    Text(selectedPlan.ctaText).font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Theme.brand).foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, Metrics.page)

            HStack(spacing: 16) {
                Button("購入を復元") { restore() }
                separatorDot
                Button("利用規約") { open("https://gurufuri.app/terms") }
                separatorDot
                Button("プライバシー") { open("https://gurufuri.app/privacy") }
            }
            .font(.system(size: 12)).foregroundStyle(Theme.sub)
            .padding(.bottom, 6)
        }
        .background(Theme.card)
    }

    private var separatorDot: some View { Text("·").foregroundStyle(Theme.hint) }

    // MARK: Actions

    private func purchaseSelected() {
        subscriptions.errorMessage = nil
        Task {
            guard let product = subscriptions.products.first(where: { $0.id == selectedPlanID }) else {
                subscriptions.errorMessage = "このプランは現在購入できません。StoreKitテスト構成を選択してください。"
                return
            }
            if await subscriptions.purchase(product) { onSubscribed(); dismiss() }
        }
    }

    private func restore() {
        Task { if await subscriptions.restore() { onSubscribed(); dismiss() } }
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) { openURL(url) }
    }
}
