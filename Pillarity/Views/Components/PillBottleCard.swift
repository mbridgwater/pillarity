//
//  PillBottleCard.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct PillBottleCard: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var bottle: PillBottle
    @State private var isEditing = false
    
    private var pillsPerDoseText: String {
        let n = bottle.dosageAmount
        return n == 1 ? "1 pill per dose" : "\(n) pills per dose"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Top row: name + status badges + Edit
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bottle.type.name)
                        .font(.headline)
                    Text(pillsPerDoseText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    PillStatusBadgesRow(bottle: bottle)
                    
                    Button {
                        isEditing = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Time-of-day badges row
            HStack(spacing: 8) {
                ForEach(bottle.timeOfDayBadges) { badge in
                    TimeOfDayBadge(timeOfDay: badge)
                }
            }
            .padding(.top, 4)
            
            // Pills remaining bar
            PillsRemainingBar(
                current: bottle.remainingPillCount,
                total: bottle.initialPillCount
            )
            .padding(.top, 8)
            
            // Next dose / last taken
            PillDoseInfoView(bottle: bottle)
                .padding(.top, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            // Safety lock
            SafetyLockRow(bottle: bottle)

            #if DEBUG
            VStack(alignment: .leading, spacing: 6) {
                Text("DEBUG Analytics")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Group {
                    Text("Daily (last 7): \(bottle.dailyLast7)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("Daily WeekBucket: \(bottle.dailyWeekBucket)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)

                Group {
                    Text("Weekly (last 4): \(bottle.weeklyLast4)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("Weekly MonthBucket: \(bottle.weeklyMonthBucket)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)

                Group {
                    Text("Monthly (last 12): \(bottle.monthlyLast12)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)

                // Simulate rollover (makes yesterday the last tracked date)
                Button("Simulate Day Rollover") {
                    // Pretend yesterday was the last update
                    bottle.lastDoseTrackingDate = Calendar.current
                        .date(byAdding: .day, value: -1, to: Date())!

                    bottle.updateForNewDayIfNeeded()

                    try? modelContext.save()
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .padding(.top, 6)
                
                Button("Simulate Taking 1 Pill") {
                    // Ensure analytics are up to date
                    bottle.updateForNewDayIfNeeded()

                    // Simulate taking 1 pill
                    bottle.pillsTakenToday += 1
                    bottle.remainingPillCount = max(bottle.remainingPillCount - 1, 0)
                    bottle.lastTakenAt = Date()

                    try? modelContext.save()
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
                .padding(.top, 4)

            }
            .padding(.top, 8)
            #endif

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                ConfigureMedicationView(bottle: bottle) {
                    isEditing = false
                }
            }
            .presentationDetents([.fraction(0.7), .large])
            .presentationDragIndicator(.visible)
        }
    }
}
