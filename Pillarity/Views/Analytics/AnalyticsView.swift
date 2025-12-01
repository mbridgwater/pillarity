//
//  AnalyticsView.swift
//  Pillarity
//

import SwiftUI
import SwiftData

// MARK: - Range Enum
enum AnalyticsRange {
    case week
    case month
    case year

    var title: String {
        switch self {
        case .week: return "Last 7 Days"
        case .month: return "Last 4 Weeks"
        case .year: return "Last 12 Months"
        }
    }
}

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession

    @State private var selectedRange: AnalyticsRange = .week

    @Query(sort: \PillBottle.createdAt, order: .reverse)
    private var allBottles: [PillBottle]

    var bottlesForUser: [PillBottle] {
        guard let user = session.currentUser else { return [] }
        return allBottles.filter { $0.owner == user }
    }

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Header
            Text("Analytics")
                .font(.title2.bold())
                .padding(.top, 8)

            // MARK: - Segmented Picker
            Picker("", selection: $selectedRange) {
                Text("Week").tag(AnalyticsRange.week)
                Text("Month").tag(AnalyticsRange.month)
                Text("Year").tag(AnalyticsRange.year)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // MARK: - Chart Placeholder
            chartSection
                .padding(.horizontal)

            // MARK: - Summary
            summarySection
                .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Chart Placeholder
extension AnalyticsView {
    var chartSection: some View {
        VStack {
            Text(selectedRange.title)
                .font(.headline)

            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("Chart coming soon")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                )
        }
    }
}

// MARK: - Summary Section
extension AnalyticsView {
    var summarySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Summary")
                .font(.headline)

            Text("Total pills taken: \(totalPillsForCurrentRange)")
                .font(.subheadline)

            Text("Medications tracked: \(bottlesForUser.count)")
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Calculations
extension AnalyticsView {
    var totalPillsForCurrentRange: Int {
        switch selectedRange {
        case .week:
            return bottlesForUser.flatMap { $0.dailyLast7 }.reduce(0, +)
        case .month:
            return bottlesForUser.flatMap { $0.weeklyLast4 }.reduce(0, +)
        case .year:
            return bottlesForUser.flatMap { $0.monthlyLast12 }.reduce(0, +)
        }
    }
}
