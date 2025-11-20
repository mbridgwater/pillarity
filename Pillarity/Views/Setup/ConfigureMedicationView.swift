//
//  ConfigureMedicationView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

struct ConfigureMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    
    let pill: Pill
    let initialPillCount: Int
    let onDone: () -> Void
    let bottleToEdit: PillBottle?
    
    // Form state
    @State private var medName: String
    @State private var dosageAmount: Int = 1        // pills per dose
    @State private var frequency: DoseFrequency = .onceDaily
    @State private var doseTime: Date = ConfigureMedicationView.defaultDoseTime()
    @State private var pillCount: Int
    @State private var saveError: String?
    private var isEditingExisting: Bool {
        bottleToEdit != nil
    }
    
    // new bottle flow
    init(pill: Pill, initialPillCount: Int, onDone: @escaping () -> Void) {
        self.pill = pill
        self.initialPillCount = initialPillCount
        self.onDone = onDone
        self.bottleToEdit = nil
        
        _medName = State(initialValue: pill.name)
        _pillCount = State(initialValue: max(initialPillCount, 1))
    }
    
    // edit bottle flow
    init(bottle: PillBottle, onDone: @escaping () -> Void) {
        self.pill = bottle.type
        self.initialPillCount = bottle.initialPillCount
        self.onDone = onDone
        self.bottleToEdit = bottle
        
        _medName      = State(initialValue: bottle.type.name)
        _dosageAmount = State(initialValue: bottle.dosageAmount)
        _frequency    = State(initialValue: bottle.frequency)
        _doseTime     = State(initialValue: bottle.firstDoseTime)
        _pillCount    = State(initialValue: max(bottle.initialPillCount, 1))
    }
    
    
    // Info text shown for multi-dose schedules.
    private var multiDoseInfoText: String? {
        switch frequency {
        case .onceDaily:
            return nil
        case .twiceDaily:
            return "Default times: 8:00 AM and 5:00 PM."
        case .threeTimesDaily:
            return "Default times: 8:00 AM, 1:00 PM, and 6:00 PM."
        }
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
                
                // Row: Dosage Amount + Frequency
                HStack(alignment: .top, spacing: 12) {
                    
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Dose Time")
                            .font(.subheadline.weight(.medium))
                        
                        DatePicker(
                            "",
                            selection: $doseTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disabled(frequency != .onceDaily)
                        .opacity(frequency == .onceDaily ? 1.0 : 0.5)
                        
                        // Info line for multi-dose defaults
                        if let info = multiDoseInfoText {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(info)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
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
                            .disabled(isEditingExisting)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .opacity(isEditingExisting ? 0.5 : 1.0)
                    }
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
                .background(Color("AccentColor").opacity(0.12))
                .foregroundColor(Color(.black))
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
        
        .onChange(of: frequency) { oldValue, newValue in
            if newValue != .onceDaily {
                doseTime = ConfigureMedicationView.defaultDoseTime()
            }
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
        
        if let bottle = bottleToEdit {
            // edit existing bottle
//            bottle.initialPillCount  = pillCount
//            bottle.remainingPillCount = min(bottle.remainingPillCount, pillCount)
            bottle.dosageAmount      = dosageAmount
            bottle.frequency         = frequency
            bottle.firstDoseTime     = doseTime
        } else {
            // create new bottle
            let bottle = PillBottle(
                type: pill,
                owner: user,
                initialPillCount: pillCount, // from Picker
                remainingPillCount: pillCount,
                dosageAmount: dosageAmount,    // from Picker
                frequency: frequency,          // from Picker
                firstDoseTime: doseTime,       // DatePicker
                lastTakenAt: nil,              // no doses yet
                safetyLockEnabled: false       // default
            )
            
            modelContext.insert(bottle)
        }
            
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
