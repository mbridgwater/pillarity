//
//  ConfigureMedicationView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

//enum DoseFrequency: String, CaseIterable, Identifiable {
//    case onceDaily = "Once daily"
//    case twiceDaily = "Twice daily"
//    case threeTimesDaily = "Thrice daily"
//
//    var id: String { rawValue }
//}

struct ConfigureMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss

    let pill: Pill
    let initialPillCount: Int
    let onDone: () -> Void

    // Form state
    @State private var medName: String
    @State private var dosageAmount: Int = 1        // pills per dose
    @State private var frequency: DoseFrequency = .onceDaily
    @State private var doseTime: Date = ConfigureMedicationView.defaultDoseTime()
    @State private var pillCount: Int
    @State private var saveError: String?

    // Custom init so we can prefill state from pill / initialPillCount
    init(pill: Pill, initialPillCount: Int, onDone: @escaping () -> Void) {
        self.pill = pill
        self.initialPillCount = initialPillCount
        self.onDone = onDone

        _medName = State(initialValue: pill.name)
        _pillCount = State(initialValue: max(initialPillCount, 1))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .center, spacing: 4) {
                    Text("Configure Medication")
                        .font(.title)
                        .bold()
                    Text("Set up your medication schedule.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)

                // Medication Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medication Name")
                        .font(.subheadline.weight(.medium))
                    TextField("e.g., Lisinopril 10mg", text: $medName)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                // Dosage Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dosage Amount")
                        .font(.subheadline.weight(.medium))
                    Picker("", selection: $dosageAmount) {
                        ForEach(1..<6) { amount in
                            Text(amount == 1 ? "1 pill" : "\(amount) pills")
                                .tag(amount)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Frequency
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency")
                        .font(.subheadline.weight(.medium))
                    Picker("", selection: $frequency) {
                        ForEach(DoseFrequency.allCases) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Dose time (first dose)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dose Time")
                        .font(.subheadline.weight(.medium))
                    DatePicker(
                        "",
                        selection: $doseTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Initial pill count
                VStack(alignment: .leading, spacing: 8) {
                    Text("Initial Pill Count")
                        .font(.subheadline.weight(.medium))

                    HStack {
                        Stepper(
                            value: $pillCount,
                            in: 1...500
                        ) {
                            Text("\(pillCount)")
                                .font(.body)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                // Calibrated pill weight banner
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(
                        String(
                            format: "Pill weight calibrated: %.1f g per pill",
                            pill.calibratedWeight
                        )
                    )
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGreen).opacity(0.12))
                .foregroundColor(Color(.systemGreen))
                .cornerRadius(12)

                if let error = saveError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                }

                // Save button
                Button {
                    saveMedication()
                } label: {
                    Text("Save Medication")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private func saveMedication() {
        saveError = nil

        guard let user = session.currentUser else {
            saveError = "No logged-in user. Please sign in again."
            return
        }

        let trimmedName = medName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            saveError = "Please enter a medication name."
            return
        }

        // Update pill name from the form
        pill.name = trimmedName

        let bottle = PillBottle(
            type: pill,
            owner: user,
            pillCount: pillCount,          // remaining pills
            dosageAmount: dosageAmount,    // from Picker
            frequency: frequency,          // from Picker
            firstDoseTime: doseTime,       // DatePicker
            lastTakenAt: nil,              // no doses yet
            safetyLockEnabled: false       // default
        )

        modelContext.insert(bottle)

        onDone()
        dismiss()
    }

    private static func defaultDoseTime() -> Date {
        // Today at 8:00 AM
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
}
