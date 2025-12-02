import SwiftUI
import AcaiaSDK
import CoreBluetooth

final class BluetoothGate: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var isReady = false

    private var central: CBCentralManager!

    override init() {
        super.init()
        // This will trigger the system permission alert on first use
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Only allow scanning when Bluetooth is actually powered on
        isReady = (central.state == .poweredOn)
    }
}

struct ConnectScaleView: View {
    let onDone: () -> Void

    @State private var scaleName = "This might take a moment"
    @State private var isTareComplete = false
    @State private var hasStartedConnection = false
    @StateObject private var bluetoothGate = BluetoothGate()

    var body: some View {
        VStack(spacing: 28) {

            // --- HEADER SECTION ---
            VStack(spacing: 6) {
                Text("Connect to Pillarity")
                    .font(.title).bold()
                    .foregroundColor(.primary)

                Text("Let's get you set up with us!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            // --- ICON SECTION ---
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .opacity(0.25)
                    .frame(width: 120, height: 120)

                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 44))
                    .foregroundColor(Color.accentColor)
            }
            .padding(.top, 4)

            // --- STATUS SECTION ---
            VStack(spacing: 24) {

                if !hasStartedConnection {
                    // STEP 1: Ask user to place bottle and show button
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calibration Instructions")
                            .font(.headline)
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. Empty the bottle completely")
                            Text("2. Place the empty pill bottle on the scale")
                            Text("3. Tap \"Start Search For Bottle\"")
                            Text("4. Tap \"Next: Configure Pill\"")
                        }
                        .foregroundColor(.primary)
                        .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    

                    Button {
                        hasStartedConnection = true
                        if bluetoothGate.isReady {
                            setupConnectionFlow()
                        } else {
                            scaleName = "Waiting for Bluetooth permission…"
                            // `setupConnectionFlow` will be called when Bluetooth becomes ready
                        }
                    } label: {
                        Text("Start Search For Bottle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))

                } else {
                    // STEP 2: Existing connection / tare flow
                    Text(scaleName)
                        .font(.title3)
                        .padding(.top, 6)

                    if isTareComplete {
                        Text("Bottle Ready!")
                            .font(.headline)
                            .foregroundColor(.primary)

                        NavigationLink("Next: Configure Pill") {
                            PillPlacementView(onDone: onDone)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))

                    } else {
                        ProgressView("Searching for nearby bottles…")
                    }
                }
            }
            .padding(.top, 10)

            Spacer()
        }
        .onReceive(bluetoothGate.$isReady) { ready in
            // If user already tapped “Start” and Bluetooth just became ready, start scanning
            if ready && hasStartedConnection && !isTareComplete {
                setupConnectionFlow()
            }
        }
    }

    // MARK: - Setup Logic

    private func setupConnectionFlow() {
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
            scale.tare()
            isTareComplete = false
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
            object: nil, queue: .main
        ) { notification in
            guard let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float else { return }

            // weight ~ 0 => tare done
            if abs(w) < 0.3 {
                isTareComplete = true
            }
        }
    }
}
