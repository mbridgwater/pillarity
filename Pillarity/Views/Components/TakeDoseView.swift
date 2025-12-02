//
//  TakeDoseView.swift
//  Pillarity
//

import SwiftUI
import AcaiaSDK
import SwiftData
import UserNotifications

struct TakeDoseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject var session: AppSession   // NEW: for debug mode
    
    @State private var stableCount = 0
    @State private var connectionStart = Date()
    @State private var currentWeight: Float = 0
    @State private var scaleReady = false
    @State private var lastWeight: Float = 9999
    @State private var tareRetryCount = 0
    let maxTareRetries = 5

    let bottle: PillBottle

    // MARK: - Computed Values
    private var pillName: String { bottle.type.name }
    private var doseAmount: Int { bottle.dosageAmount }

    private var doseTimeString: String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: bottle.firstDoseTime)
    }

    var body: some View {
        VStack(spacing: 24) {

            if !scaleReady {
                // ---------------------------------------------------------
                // MARK: CONNECTING STATE
                // ---------------------------------------------------------
                VStack(spacing: 12) {
                    Text("Connecting to your bottle…")
                        .font(.title.bold())

                    Text("Preparing your scale to zero…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView()
                        .padding(.top, 4)

                    // DEBUG-ONLY weight capsule
                    if session.debugModeEnabled {
                        Text("Current weight: \(String(format: "%.2f g", currentWeight))")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                    }
                }

            } else {
                // ---------------------------------------------------------
                // MARK: READY STATE
                // ---------------------------------------------------------
                VStack(spacing: 16) {

                    // Header
                    Text("Time to take your pill\(doseAmount == 1 ? "" : "s")!")
                        .font(.title.bold())

                    // Pink accent info box
                    VStack(spacing: 6) {
                        Text("\(pillName)")
                            .font(.headline)
                            .foregroundColor(Color(.black))

                        Text("\(doseAmount) pill\(doseAmount == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(Color(.black))

                        Text("\(doseTimeString) dose")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("AccentColor").opacity(0.20))
                    .cornerRadius(14)

                    // Instructions
                    Text("Remove your pill\(doseAmount == 1 ? "" : "s") from the bottle.")
                        .font(.subheadline)

                    // Weight (Debug Only)
                    if session.debugModeEnabled {
                        VStack(spacing: 4) {
                            Text("Current weight: \(String(format: "%.2f g", currentWeight))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }

                    // Take pill button
                    Button("I took my pill!") {
                        confirmTaken()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupScale()
        }
    }
    
    private func adaptiveTare() {
        guard let scale = AcaiaManager.shared().connectedScale else { return }

        tareRetryCount = 0
        lastWeight = currentWeight   // track initial weight

        // First tare immediately
        scale.tare()

        // Begin adaptive checking
        attemptAdaptiveTare()
    }

    private func attemptAdaptiveTare() {
        guard let scale = AcaiaManager.shared().connectedScale else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            // If weight changed OR stabilized near zero → tare succeeded
            if abs(self.currentWeight - self.lastWeight) > 0.05 || abs(self.currentWeight) < 0.2 {
                // Tare worked
                return
            }

            // Weight hasn't moved → try again
            self.tareRetryCount += 1

            if self.tareRetryCount <= self.maxTareRetries {
                scale.tare()
                self.lastWeight = self.currentWeight
                self.attemptAdaptiveTare()
            }
        }
    }


    // MARK: - Scale Setup
    private func setupScale() {

        // When scale connects → tare immediately
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleDidConnected),
            object: nil,
            queue: .main
        ) { _ in
            self.scaleReady = false
            self.stableCount = 0
            self.connectionStart = Date()

            // Use retrying tare (fixes the stuck issue)
            self.adaptiveTare()
        }


        // Weight updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil,
            queue: .main
        ) { notif in
            if let w = notif.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float {
                self.currentWeight = w
                let now = Date()

                // 1. Check stability (more forgiving than 0.05)
                if abs(w) <= 0.20 {
                    stableCount += 1
                } else {
                    stableCount = 0
                }

                // 2. Ready if stable for several readings
                if stableCount >= 3 {
                    self.scaleReady = true
                    return
                }

                // 3. Timeout fallback after 5 sec
                if now.timeIntervalSince(connectionStart) > 5 {
                    self.scaleReady = true
                    return
                }
            }
        }


        // Begin BLE scan
        AcaiaManager.shared().startScan(1.0)

        // If already connected, tare immediately
//        AcaiaManager.shared().connectedScale?.tare()
        adaptiveTare()
    }

    // MARK: - Confirm Taken
    private func confirmTaken() {
        bottle.updateForNewDayIfNeeded()

        let removedWeight = abs(currentWeight)
        let pillWeight = bottle.type.calibratedWeight
        let pillsTaken = max(Int(round(removedWeight / pillWeight)), 0)

        bottle.pillsTakenToday += pillsTaken
        bottle.remainingPillCount = max(bottle.remainingPillCount - pillsTaken, 0)
        bottle.lastTakenAt = Date()

        try? ctx.save()
        dismiss()
    }
}
