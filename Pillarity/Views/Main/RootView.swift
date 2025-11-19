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
        } else {
            AuthRootView()
        }
    }
}
