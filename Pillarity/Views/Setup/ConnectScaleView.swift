import SwiftUI
import AcaiaSDK

struct ConnectScaleView: View {
    let onDone: () -> Void
    @State private var scaleName = "Connecting to Pillarity bottle…"
    @State private var isTareComplete = false

    var body: some View {
        VStack(spacing: 30) {

            Text(scaleName)
                .font(.title2)
                .padding()

            if isTareComplete {
                Text("Bottle ready")
                    .font(.headline)
                    .foregroundColor(.primary)

                NavigationLink("Next") {
                    PillPlacementView(onDone: onDone)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))

            } else {
                ProgressView("Searching for nearby bottles…")
            }
        }
        .onAppear {
            #if targetEnvironment(simulator)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.scaleName = "Simulated Bottle"
                self.isTareComplete = true
            }
            #else
            setupObservers()
            AcaiaManager.shared().startScan(1.0)
            #endif
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
            scaleName = "Pillarity Bottle Connected: \(scale.name)"
            scale.tare()                   // Zero scale once only
            isTareComplete = false         // Wait for tare to finish
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil, queue: .main
        ) { notification in
            guard let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float else { return }

            if abs(w) < 0.3 {
                // Weight ~ zero = tare finished
                isTareComplete = true
            }
        }
    }
}
