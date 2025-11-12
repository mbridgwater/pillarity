import SwiftUI
import AcaiaSDK

struct ContentView: View {
    @State private var scaleName: String = "No scale connected"
    @State private var weight: String = "-"

    var body: some View {
        VStack(spacing: 20) {
            Text(scaleName).font(.title2)
            Text(weight).font(.system(size: 40, weight: .bold, design: .rounded))

            Button("Scan for Scales") {
                AcaiaManager.shared().startScan(1.0)
                print("Started scanning for scales…")
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            AcaiaManager.shared().enableBackgroundRecovery = true

            // When scan finishes: list scales and connect to the first one.
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(rawValue: AcaiaScaleDidFinishScan),
                object: nil,
                queue: .main
            ) { _ in
                let scales = AcaiaManager.shared().scaleList
                if scales.isEmpty {
                    print("Scan finished: no scales found")
                } else {
                    for s in scales { print("Scan finished: found scale \(s.name)") }
                    if let first = scales.first {
                        first.connect() // <- per example
                        print("Attempting to connect to \(first.name)")
                    }
                }
            }

            // When a scale connects: update name.
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(rawValue: AcaiaScaleDidConnected),
                object: nil,
                queue: .main
            ) { _ in
                if let scale = AcaiaManager.shared().connectedScale {
                    scaleName = "Connected: \(scale.name)"
                    print("Connected to \(scale.name)")
                }
            }

            // Weight updates.
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
                object: nil,
                queue: .main
            ) { notification in
                if let value = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float {
                    weight = String(format: "%.1f g", value)
                    print("Weight updated: \(value) g")
                }
            }
        }
    }
}

#Preview { ContentView() }
