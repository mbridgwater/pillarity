//
//  SignInView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession

    @Binding var showingSignUp: Bool

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome Back")
                    .font(.headline)
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Card container
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline.weight(.medium))
                    TextField("you@example.com", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline.weight(.medium))
                    SecureField("••••••••", text: $password)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    signIn()
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.05), radius: 12, y: 6)

            Button {
                showingSignUp = true
            } label: {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                    Text("Sign Up").fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
            }
            .padding(.top, 4)
            
//            Button {
//                signInDemoUser()
//            } label: {
//                Text("Sign in as Demo User")
//                    .font(.subheadline)
//                    .foregroundColor(.blue)
//                    .underline()
//            }
//            .padding(.top, 4)

        }
    }

    private func signIn() {
        errorMessage = nil

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        Task {
            do {
                let descriptor = FetchDescriptor<User>(
                    predicate: #Predicate { $0.email == email && $0.password == password }
                )
                let users = try modelContext.fetch(descriptor)

                if let user = users.first {
                    // Success – move into app
                    await MainActor.run {
                        session.currentUser = user
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Invalid email or password."
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong. Please try again."
                }
            }
        }
    }
    
//    private func signInDemoUser() {
//        Task {
//            let descriptor = FetchDescriptor<User>(
//                predicate: #Predicate { $0.email == "demo@pillarity.app" }
//            )
//            if let demo = try? modelContext.fetch(descriptor).first {
//                await MainActor.run {
//                    session.currentUser = demo
//                }
//            }
//        }
//    }

}
