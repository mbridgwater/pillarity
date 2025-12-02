//
//  RootView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        if let _ = session.currentUser {
            MainShellView()
            .environmentObject(session)
            .preferredColorScheme(session.isDarkModeEnabled ? .dark : .light) // Default = light; toggle will flip to dark
        } else {
            AuthRootView()
        }
    }
}
