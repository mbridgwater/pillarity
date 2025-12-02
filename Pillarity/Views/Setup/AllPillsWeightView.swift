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
    
    let pill: Pill
    let onDone: () -> Void

    @State private var totalWeight: Float = 0
    @State private var calculatedCount: Int? = nil
    @State private var navigateToConfigure = false

    private var numPills: Int { max(calculatedCount ?? 0, 1) }

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
                    Text("3. Tap \"Next: Configure Medication\"")
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)

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

                        Button {
                            navigateToConfigure = true
                        } label: {
                            Text("Next: Configure Medication")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)
                } else {
                    Text("Calculating pill count…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupWeightObserver(singlePillWeight: singlePillWeight)
        }
        .navigationDestination(isPresented: $navigateToConfigure) {
            ConfigureMedicationView(
                pill: pill,
                initialPillCount: numPills,
                onDone: onDone
            )
        }
    }

    // Weight updates
    private func setupWeightObserver(singlePillWeight: Float) {
        guard singlePillWeight > 0 else {
            print("Cannot compute pill count without a calibrated pill weight.")
            return
        }

        #if targetEnvironment(simulator)
        let simulatedCount: Float = 10
        let simulatedTotal = simulatedCount * singlePillWeight

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.totalWeight = simulatedTotal
            self.updateCalculatedCount(singlePillWeight: singlePillWeight)
        }
        return
        #endif

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
    }
}
