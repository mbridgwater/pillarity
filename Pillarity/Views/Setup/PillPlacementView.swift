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
    @State private var statusMessage = ""
    @State private var placed = false
    
    @State private var pillName: String = ""
    @State private var calibratedPill: Pill? = nil

    var body: some View {
        VStack(spacing: 28) {
            
            VStack(spacing: 6) {
                Text("Calibrate Pill Weight")
                    .font(.title).bold()
                    .foregroundColor(.primary)
                Text("Let's measure how much each pill weighs.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .opacity(0.3)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "scalemass")
                    .font(.system(size: 44))
                    .foregroundColor(Color.accentColor)
            }
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Calibration Instructions")
                    .font(.headline)
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("1. Empty the bottle completely")
                    Text("2. Place ONE pill in the bottle")
                    Text("3. Click \"Start Calibration\"")
                    Text("4. Wait for the weight to stabilize")
                }
                .foregroundColor(.primary)
                .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name this pill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("e.g. Vitamin D", text: $pillName)
                    .textFieldStyle(.roundedBorder)
                    .disabled(placed)
                    .opacity(placed ? 0.6 : 1.0)
            }
            .padding(.horizontal)
            
            Text(statusMessage)
                .font(.title)
                .multilineTextAlignment(.center)

            if !placed {
                Button("Start Calibration") {
                    finishCalibration()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
                .disabled(pillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(pillName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            } else {
                if let pill = calibratedPill {
                    NavigationLink("Next: Configure Bottle") {
                        AllPillsWeightView(pill: pill, onDone: onDone)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
                } else {
                    Text("Error: pill calibration not saved.")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                
            }
        }
        .onAppear { setupWeightObserver() }
        .padding(.bottom, 20)
    }

    private func setupWeightObserver() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.latestWeight = 3.2
        }
        return
        #endif

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

        statusMessage = "\(formatted)"

        let newPill = Pill(name: pillName, calibratedWeight: latestWeight)
        modelContext.insert(newPill)
        calibratedPill = newPill
    }
}
