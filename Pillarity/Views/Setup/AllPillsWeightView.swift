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
    @EnvironmentObject var session: AppSession
    
    let pill: Pill
    let onDone: () -> Void

    @State private var totalWeight: Float = 0
    @State private var calculatedCount: Int? = nil
    @State private var userCount: Int = 0
    @State private var userAdjusted = false

    @State private var statusMessage = "Place all pills of this type in the bottle."

    var body: some View {
        let singlePillWeight = pill.calibratedWeight

        VStack(spacing: 24) {

            // Header
            VStack(spacing: 4) {
                Text("Calibrate Bottle Weight")
                    .font(.title)
                    .bold()
                Text("Let's measure how many pills are in this bottle.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0xF9/255, green: 0xD2/255, blue: 0xE4/255))
                    .frame(width: 140, height: 140)

                Image(systemName: "scalemass")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundColor(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
            }
            .padding(.top, 8)

            // Instructions card
            VStack(alignment: .leading, spacing: 12) {
                Text("Calibration Instructions")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("1. Place ALL pills of this type in the bottle")
                    Text("2. Wait for the pill count to stabilize")
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)

            // Optional status / error text
            if singlePillWeight <= 0 {
                Text("No calibrated weight found for this pill. Go back and calibrate a single pill first.")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Main count UI
            if singlePillWeight > 0 {
                if let count = calculatedCount {
                    VStack(spacing: 16) {
                        Text("We think you have \(count) pills in this bottle.")
                            .font(.headline)
                            .multilineTextAlignment(.center)

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
                    .padding(.top, 8)
                } else {
                    Text("Calculating pill count…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }

                // Manual adjustment section
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
                    .padding(.top, 6)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupWeightObserver(singlePillWeight: singlePillWeight)
        }
    }

    // MARK: - Weight updates

    private func setupWeightObserver(singlePillWeight: Float) {
        guard singlePillWeight > 0 else {
            statusMessage = "Cannot compute pill count without a calibrated pill weight."
            return
        }

        #if targetEnvironment(simulator)
        // Simulator: fake some data
        let simulatedCount: Float = 10
        let simulatedTotal = simulatedCount * singlePillWeight

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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

        if !userAdjusted {
            userCount = count
        }
    }

    // MARK: - Save pill bottle

    private func saveBottle(finalCount: Int) {
        guard let user = session.currentUser else {
            print("❌ No current user in session; cannot attach owner to bottle")
            return
        }
        
        let bottle = PillBottle(type: pill, pillCount: finalCount, owner: user)
        modelContext.insert(bottle)

        statusMessage = "Saved \(finalCount) pills for \(pill.name)."
        onDone()
    }
}
