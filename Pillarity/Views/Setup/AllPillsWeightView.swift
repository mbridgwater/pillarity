//
//  AllPillsWeightView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData
import AcaiaSDK

struct AllPillsWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let pill: Pill
    let onDone: () -> Void

    @State private var totalWeight: Float = 0
    @State private var calculatedCount: Int? = nil
    @State private var userCount: Int = 0
    @State private var userAdjusted = false   // if user pressed "No" and started editing

    @State private var statusMessage = "Put all the pills of this type in the bottle."

    var body: some View {
        let singlePillWeight = pill.calibratedWeight

        VStack(spacing: 24) {
            Text(statusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(pill.name)
                .font(.subheadline)

            if singlePillWeight > 0 {
                Text(String(format: "Calibrated weight per pill: %.1f g", singlePillWeight))
                    .font(.subheadline)
            } else {
                Text("No calibrated weight found for this pill type.")
                    .foregroundColor(.red)
            }

            Text(String(format: "Measured total weight: %.1f g", totalWeight))
                .font(.title3)

            if let count = calculatedCount, singlePillWeight > 0 {
                Text("We think you have \(count) pills in this bottle.")
                    .font(.headline)
                    .padding(.top, 8)

                // Yes / No confirmation
                HStack(spacing: 20) {
                    Button("Yes, that's correct") {
                        saveBottle(finalCount: count)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("No") {
                        userAdjusted = true
                        userCount = count
                    }
                    .buttonStyle(.bordered)
                }
            }

            if userAdjusted {
                VStack(spacing: 12) {
                    Text("Adjust pill count")
                        .font(.subheadline)

                    HStack(spacing: 20) {
                        Button("-") {
                            if userCount > 0 { userCount -= 1 }
                        }
                        .font(.title2)

                        Text("\(userCount) pills")
                            .font(.title3)

                        Button("+") {
                            userCount += 1
                        }
                        .font(.title2)
                    }

                    Button("Save corrected count") {
                        saveBottle(finalCount: userCount)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 12)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupWeightObserver(singlePillWeight: singlePillWeight)
        }
    }

    // Weight updates

    private func setupWeightObserver(singlePillWeight: Float) {
        guard singlePillWeight > 0 else {
            statusMessage = "Cannot compute pill count without a calibrated pill weight."
            return
        }

        #if targetEnvironment(simulator)
        // Simulator
        let simulatedCount: Float = 10
        let simulatedTotal = simulatedCount * singlePillWeight

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.totalWeight = simulatedTotal
            self.updateCalculatedCount(singlePillWeight: singlePillWeight)
        }
        return
        #endif

        // Real device
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil, queue: .main
        ) { notification in
            if let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float {
                totalWeight = w
                updateCalculatedCount(singlePillWeight: singlePillWeight)
            }
        }
    }

    private func updateCalculatedCount(singlePillWeight: Float) {
        guard singlePillWeight > 0 else { return }

        let raw = totalWeight / singlePillWeight
        let count = max(Int(round(raw)), 0)

        calculatedCount = count

        // Only auto-update the editable count until the user says "No"
        if !userAdjusted {
            userCount = count
        }
    }

    // Save pill bottle
    private func saveBottle(finalCount: Int) {
        let bottle = PillBottle(type: pill, pillCount: finalCount)
        modelContext.insert(bottle)
        statusMessage = "Saved \(finalCount) pills for \(pill.name)."
        
        onDone()
    }
}
