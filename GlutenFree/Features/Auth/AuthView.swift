import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= (isRegistering ? 8 : 1) && !session.isWorking
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("GlutenFree")
                .font(.largeTitle.bold())
            Text("Gluten-free dining in Tokyo")
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(isRegistering ? .newPassword : .password)
            }
            .textFieldStyle(.roundedBorder)

            if isRegistering {
                Text("Password must be at least 8 characters.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let error = session.authError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: submit) {
                Group {
                    if session.isWorking {
                        ProgressView().tint(.white)
                    } else {
                        Text(isRegistering ? "Create account" : "Sign in")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSubmit)

            Button(isRegistering ? "Have an account? Sign in" : "New here? Create an account") {
                isRegistering.toggle()
                session.authError = nil
            }
            .font(.footnote)

            Spacer()
        }
        .padding()
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
}
