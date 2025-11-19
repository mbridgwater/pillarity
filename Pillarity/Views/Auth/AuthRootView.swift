//
//  AuthRootView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI

struct AuthRootView: View {
    @State private var showingSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Logo + title
                VStack(spacing: 12) {
                    Image("PillarityLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 8, y: 4)

                    Text("Pillarity")
                        .font(.title.weight(.semibold))

                }
                .padding(.top, 60)

                Spacer(minLength: 0)

                if showingSignUp {
                    SignUpView(showingSignUp: $showingSignUp)
                } else {
                    SignInView(showingSignUp: $showingSignUp)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
