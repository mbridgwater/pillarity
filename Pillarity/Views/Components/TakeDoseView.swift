import SwiftUI
import AcaiaSDK
import SwiftData
import UserNotifications

struct TakeDoseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    @State private var currentWeight: Float = 0
    @State private var scaleReady = false

    let bottle: PillBottle

    var body: some View {
        VStack(spacing: 24) {

            Text("Time to take your pill!")
                .font(.title.bold())

            Text("Remove your pill from the bottle.")
                .font(.subheadline)

            Text("Weight: \(String(format: "%.2f g", currentWeight))")
                .font(.headline)

            if scaleReady {
                Button("I took my pill!") {
                    confirmTaken()
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView("Preparing scale…")
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupScale()
        }
    }

    private func setupScale() {

        // Observer: when scale connects, tare immediately
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleDidConnected),
            object: nil,
            queue: .main
        ) { _ in
            AcaiaManager.shared().connectedScale?.tare()
            self.scaleReady = false  // wait until weight returns to ~0
        }

        // Observer: weight updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil,
            queue: .main
        ) { notif in
            if let w = notif.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float {
                self.currentWeight = w

                // scale considered ready when stabilized at zero
                if abs(w) <= 0.05 {
                    self.scaleReady = true
                }
            }
        }

        // Start BLE scan
        AcaiaManager.shared().startScan(1.0)

        // Try taring immediately if already connected
        AcaiaManager.shared().connectedScale?.tare()
    }


    private func confirmTaken() {
        bottle.resetIfNewDay()

        let removedWeight = abs(currentWeight)
        let pillWeight = bottle.type.calibratedWeight
        let pillsTaken = max(Int(floor(removedWeight / pillWeight)), 0)


        // update bottle
        bottle.pillsTakenToday += pillsTaken
        bottle.remainingPillCount = max(bottle.remainingPillCount - pillsTaken, 0)
        bottle.lastTakenAt = Date()

        try? ctx.save()
        dismiss()

    }
}
