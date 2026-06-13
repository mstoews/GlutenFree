import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let user = session.user {
                        LabeledContent("Email", value: user.email)
                    }
                }

                Section("Subscription") {
                    LabeledContent("Status") {
                        Text(statusText)
                            .foregroundStyle(session.isSubscribed ? .green : .secondary)
                    }
                    if let expiry = Formatters.date(session.subscription?.subExpiresAt) {
                        LabeledContent(session.isSubscribed ? "Renews" : "Expired", value: expiry)
                    }
                    if session.isSubscribed {
                        Button("Restore purchases") {
                            Task { await subscriptions.restore() }
                        }
                    } else {
                        Button("Subscribe") { showPaywall = true }
                    }
                }

                Section {
                    Button("Sign out", role: .destructive) { session.logout() }
                }
            }
            .navigationTitle("Account")
            .task { await session.loadSubscription() }
            .refreshable { await session.loadSubscription() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private var statusText: String {
        (session.subscription?.subscriptionStatus ?? session.user?.subscriptionStatus ?? "free").capitalized
    }
}
