//
//  PillPlacementView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData
import AcaiaSDK

struct PillPlacementView: View {
    @Environment(\.modelContext) private var modelContext
    let onDone: () -> Void
    
    @State private var latestWeight: Float = 0
    @State private var statusMessage = "Please place the pill on the scale."
    @State private var placed = false
    
    @State private var pillName: String = "Pill Type"
    @State private var calibratedPill: Pill? = nil

    var body: some View {
        VStack(spacing: 30) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name this pill type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("e.g. Vitamin D", text: $pillName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
            
            Text(statusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)

            if !placed {
                Button("Yes, I placed it") {
                    finishCalibration()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
            } else {
                if let pill = calibratedPill {
                    NavigationLink("Next: put all pills on the scale") {
                        AllPillsWeightView(pill: pill, onDone: onDone)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
                } else {
                    // Shouldn’t really happen, but nice fallback
                    Text("Error: pill calibration not saved.")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .onAppear { setupWeightObserver() }
        .padding()
    }

    private func setupWeightObserver() {
        #if targetEnvironment(simulator)
        // Simulator: mock a single pill weight
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.latestWeight = 3.2
        }
        return
        #endif

        // Real device
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil, queue: .main
        ) { notification in
            if let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float {
                latestWeight = w
            }
        }
    }

    private func finishCalibration() {
        placed = true
        let formatted = String(format: "%.1f g", latestWeight)

        statusMessage = """
        Successfully calibrated \(pillName)
        as \(formatted)
        """

        // Create and save this pill type
        let newPill = Pill(name: pillName, calibratedWeight: latestWeight)
        modelContext.insert(newPill)

        // Keep a reference so we can pass it to the next screen
        calibratedPill = newPill
    }
}
