//
//  SignUpView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession

    @Binding var showingSignUp: Bool

    @State private var selectedAccountType: AccountType = .patient
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Account")
                    .font(.headline)
                Text("Sign up to start tracking your medication")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                // Account type picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Type")
                        .font(.subheadline.weight(.medium))
                    Menu {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                selectedAccountType = type
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedAccountType.rawValue)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.subheadline.weight(.medium))

                    ZStack(alignment: .leading) {
                        if name.isEmpty {
                            Text("Your Name")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 12)
                        }

                        TextField("", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding(12)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
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
                    signUp()
                } label: {
                    Text("Sign Up")
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
                showingSignUp = false
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                    Text("Sign In").fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(Color(.systemGray))
            }
            .padding(.top, 4)
        }
    }

    private func signUp() {
        errorMessage = nil

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        Task {
            do {
                // Make sure email isn't already in use
                let existing = try modelContext.fetch(
                    FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
                )

                if !existing.isEmpty {
                    await MainActor.run {
                        errorMessage = "An account with that email already exists."
                    }
                    return
                }

                let user = User(
                    name: name,
                    email: email,
                    password: password,
                    accountType: selectedAccountType
                )
                modelContext.insert(user)

                await MainActor.run {
                    session.currentUser = user
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong. Please try again."
                }
            }
        }
    }
}
