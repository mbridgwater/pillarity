import SwiftUI
import AcaiaSDK

struct ConnectScaleView: View {
    @State private var scaleName = "Connecting to scale…"
    @State private var isTareComplete = false

    var body: some View {
        VStack(spacing: 30) {

            Text(scaleName)
                .font(.title2)
                .padding()

            if isTareComplete {
                Text("Scale Ready")
                    .font(.headline)
                    .foregroundColor(.green)

                NavigationLink("Set up new pill") {
                    PillPlacementView()
                }
                .buttonStyle(.borderedProminent)

            } else {
                ProgressView("Preparing scale…")
            }
        }
        .onAppear {
            setupObservers()
            AcaiaManager.shared().startScan(1.0)
        }
    }

    private func setupObservers() {
        AcaiaManager.shared().enableBackgroundRecovery = true

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleDidFinishScan),
            object: nil, queue: .main
        ) { _ in
            AcaiaManager.shared().scaleList.first?.connect()
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleDidConnected),
            object: nil, queue: .main
        ) { _ in
            guard let scale = AcaiaManager.shared().connectedScale else { return }
            scaleName = "Connected: \(scale.name)"
            scale.tare()                   // Zero scale once only
            isTareComplete = false         // Wait for tare to finish
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil, queue: .main
        ) { notification in
            guard let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float else { return }

            if abs(w) < 0.3 {              // Weight ~ zero = tare finished
                isTareComplete = true
            }
        }
    }
}
