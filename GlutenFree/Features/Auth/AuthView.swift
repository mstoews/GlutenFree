import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= (isRegistering ? 8 : 1) && !session.isWorking
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                form
            }
        }
        .background(Theme.page.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: Hero

    private var hero: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x059669), Color(hex: 0x065f46)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            GeometryReader { geo in
                ZStack {
                    Circle().stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                        .frame(width: 260, height: 260)
                        .position(x: geo.size.width - 24, y: 64)
                    Circle().stroke(Color.white.opacity(0.10), lineWidth: 1.5)
                        .frame(width: 170, height: 170)
                        .position(x: 28, y: geo.size.height - 12)
                }
            }
            VStack(spacing: 16) {
                wordmark
                VStack(spacing: 6) {
                    Text("安心して、外食を。")
                        .font(.system(size: 22, weight: .heavy)).foregroundStyle(.white)
                    Text("東京のグルテンフリー対応店と全メニューを、審査済みデータベースで。")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
            }
            .padding(.top, 54)
            .padding(.bottom, 28)
        }
        .frame(height: 330)
        .clipped()
    }

    private var wordmark: some View {
        VStack(spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text("グルフリ").font(.system(size: 34, weight: .heavy)).foregroundStyle(.white)
            }
            Text("G U R U F U R I")
                .font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: Form

    private var form: some View {
        VStack(spacing: 14) {
            field(icon: "envelope", placeholder: "メール", text: $email, secure: false)
            passwordField

            if isRegistering {
                Text("パスワードは8文字以上で設定してください。")
                    .font(.caption).foregroundStyle(Theme.hint)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let error = session.authError {
                Text(error).font(.footnote).foregroundStyle(Theme.systemRed)
                    .multilineTextAlignment(.center)
            }

            Button(action: submit) {
                Group {
                    if session.isWorking { ProgressView().tint(.white) }
                    else { Text(isRegistering ? "新規登録" : "ログイン").font(.system(size: 16, weight: .bold)) }
                }
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(Theme.brand).foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.5)

            dividerOr

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(session.isWorking)

            Button {
                isRegistering.toggle()
                session.authError = nil
            } label: {
                HStack(spacing: 4) {
                    Text(isRegistering ? "アカウントをお持ちの方は" : "アカウントをお持ちでない方は")
                        .foregroundStyle(Theme.sub)
                    Text(isRegistering ? "ログイン" : "新規登録")
                        .foregroundStyle(Theme.brand).fontWeight(.bold)
                }
                .font(.system(size: 13))
            }
            .padding(.top, 6)

            Text("Noble Ledger · Gurufuri v0.0.4.66")
                .font(.system(size: 11)).foregroundStyle(Theme.hint)
                .padding(.top, 12)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 24)
    }

    private func field(icon: String, placeholder: LocalizedStringKey, text: Binding<String>, secure: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(Theme.hint).frame(width: 18)
            if secure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }
        }
        .font(.system(size: 16))
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding(.horizontal, 14).frame(height: 50)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.separator, lineWidth: 1))
    }

    private var passwordField: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield").foregroundStyle(Theme.hint).frame(width: 18)
            Group {
                if showPassword { TextField("パスワード", text: $password) }
                else { SecureField("パスワード", text: $password) }
            }
            Button { showPassword.toggle() } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye").foregroundStyle(Theme.hint)
            }
        }
        .font(.system(size: 16))
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding(.horizontal, 14).frame(height: 50)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.separator, lineWidth: 1))
    }

    private var dividerOr: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Theme.separator).frame(height: 1)
            Text("または").font(.system(size: 12)).foregroundStyle(Theme.hint)
            Rectangle().fill(Theme.separator).frame(height: 1)
        }
        .padding(.vertical, 2)
    }

    private func submit() {
        Task {
            if isRegistering {
                await session.register(email: email, password: password)
            } else {
                await session.login(email: email, password: password)
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else {
                session.authError = String(localized: "Appleサインインに失敗しました。")
                return
            }
            // `email` is only present on the first authorization; forward it so a
            // new account gets a real address.
            Task { await session.signInWithApple(identityToken: identityToken, email: credential.email) }
        case .failure(let error):
            // A user-initiated cancel isn't an error worth surfacing.
            if let authError = error as? ASAuthorizationError, authError.code == .canceled { return }
            session.authError = String(localized: "Appleサインインに失敗しました。")
        }
    }
}
