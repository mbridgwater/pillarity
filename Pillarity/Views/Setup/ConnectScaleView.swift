//import SwiftUI
//import AcaiaSDK
//
//struct ConnectScaleView: View {
//    let onDone: () -> Void
//    @State private var scaleName = "Connecting to Pillarity bottle…"
//    @State private var isTareComplete = false
//
//    var body: some View {
//        VStack(spacing: 28) {
//
//            // --- HEADER SECTION ---
//            VStack(spacing: 6) {
//                Text("Connect to Pillarity")
//                    .font(.title).bold()
//                    .foregroundColor(.primary)
//
//                Text("Let's get you set up with us!")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.top, 20)
//
//            // --- ICON SECTION ---
//            ZStack {
//                Circle()
//                    .fill(Color.accentColor)
//                    .opacity(0.25)
//                    .frame(width: 120, height: 120)
//
//                // Replace with actual icon combo you want
//                Image(systemName: "wifi")
//                    .font(.system(size: 44))
//                    .foregroundColor(Color.accentColor)
//            }
//            .padding(.top, 4)
//
//            // --- STATUS SECTION ---
//            VStack(spacing: 30) {
//                Text(scaleName)
//                    .font(.title3)
//                    .padding(.top, 6)
//
//                if isTareComplete {
//                    Text("Bottle ready")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//
//                    NavigationLink("Next: Configure Pill") {
//                        PillPlacementView(onDone: onDone)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
//
//                } else {
//                    ProgressView("Searching for nearby bottles…")
//                }
//            }
//            .padding(.top, 10)
//
//            Spacer()
//        }
//        .onAppear(perform: setupConnectionFlow)
//    }
//
//    // MARK: - Setup Logic
//
//    private func setupConnectionFlow() {
//        #if targetEnvironment(simulator)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.scaleName = "Simulated Bottle"
//            self.isTareComplete = true
//        }
//        #else
//        setupObservers()
//        AcaiaManager.shared().startScan(1.0)
//        #endif
//    }
//
//    private func setupObservers() {
//        AcaiaManager.shared().enableBackgroundRecovery = true
//
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name(rawValue: AcaiaScaleDidFinishScan),
//            object: nil, queue: .main
//        ) { _ in
//            AcaiaManager.shared().scaleList.first?.connect()
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name(rawValue: AcaiaScaleDidConnected),
//            object: nil, queue: .main
//        ) { _ in
//            guard let scale = AcaiaManager.shared().connectedScale else { return }
//            scaleName = "Pillarity Bottle Connected: \(scale.name)"
//            scale.tare()
//            isTareComplete = false
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name(rawValue: AcaiaScaleWeight),
//            object: nil, queue: .main
//        ) { notification in
//            guard let w = notification.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float else { return }
//
//            if abs(w) < 0.3 {
//                isTareComplete = true
//            }
//        }
//    }
//}

import SwiftUI
import AcaiaSDK

struct ConnectScaleView: View {
    let onDone: () -> Void

    @State private var scaleName = "This might take a moment"
    @State private var isTareComplete = false
    @State private var hasStartedConnection = false

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
                            Text("3. Click \"Start Search For Bottle\"")
                            Text("4. Click \"Next: Configure Pill\"")
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
                        setupConnectionFlow()
                    } label: {
                        Text("Start Search For Bottle")
//                            .font(.headline)
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
