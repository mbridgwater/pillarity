import SwiftUI
import AcaiaSDK

struct PillPlacementView: View {
    @State private var latestWeight: Float = 0
    @State private var statusMessage = "Please place the pill on the scale."
    @State private var pillNumber = 1
    @State private var placed = false

    var body: some View {
        VStack(spacing: 30) {
            Text(statusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)

            if !placed {
                Button("Yes, I placed it") {
                    finishCalibration()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear { setupWeightObserver() }
        .padding()
    }

    private func setupWeightObserver() {
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
        Successfully calibrated Pill \(pillNumber)
        as \(formatted)
        """

        pillNumber += 1
    }
}
