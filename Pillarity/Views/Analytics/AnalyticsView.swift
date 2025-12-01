//
//  AnalyticsView.swift
//  Pillarity
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Range Enum
enum AnalyticsRange {
    case week
    case month
    case year

    var title: String {
        switch self {
        case .week: return "Past 7 Days"
        case .month: return "Past 4 Weeks"
        case .year: return "Past 12 Months"
        }
    }

    var cardTitle: String {
        switch self {
        case .week: return "Weekly Trend"
        case .month: return "Monthly Trend"
        case .year: return "Yearly Trend"
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
        ScrollView {
            VStack(spacing: 20) {

                // MARK: Header
                Text("Analytics")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                // MARK: Segmented Picker
                Picker("", selection: $selectedRange) {
                    Text("Week").tag(AnalyticsRange.week)
                    Text("Month").tag(AnalyticsRange.month)
                    Text("Year").tag(AnalyticsRange.year)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: Trend Card
                trendCard
                    .padding(.horizontal)

                // MARK: Metrics Card
                metricsCard
                    .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
    }
}

//
// MARK: - Trend Card
//
extension AnalyticsView {

    var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(selectedRange.cardTitle)
                .font(.headline)
                .padding(.top, 4)

            ChartSectionView(selectedRange: selectedRange,
                             dailyValues: summedDailyLast7,
                             weeklyValues: summedWeeklyLast4,
                             monthlyValues: summedMonthlyLast12,
                             dailyLabels: dailyLabels,
                             weeklyLabels: weeklyLabels,
                             monthlyLabels: monthlyLabels)
                .frame(height: 240)
                .padding(.bottom, 8)

        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

//
// MARK: - Metrics Card
//
extension AnalyticsView {

    var metricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(selectedRange.title)
                .font(.headline)
                .padding(.top, 4)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Taken")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalPillsForCurrentRange)")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(expectedPillsForCurrentRange)")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(bottlesForUser.count)")
                        .font(.title3.bold())
                }
            }
            .padding(.vertical, 4)

        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

//
// MARK: - Chart Section Component
//
struct ChartSectionView: View {
    let selectedRange: AnalyticsRange
    let dailyValues: [Int]
    let weeklyValues: [Int]
    let monthlyValues: [Int]
    let dailyLabels: [String]
    let weeklyLabels: [String]
    let monthlyLabels: [String]

    var body: some View {
        switch selectedRange {
        case .week:
            barChart(values: dailyValues, labels: dailyLabels)

        case .month:
            barChart(values: weeklyValues, labels: weeklyLabels)

        case .year:
            barChart(values: monthlyValues, labels: monthlyLabels)
        }
    }

    @ViewBuilder
    func barChart(values: [Int], labels: [String]) -> some View {
        Chart {
            ForEach(values.indices, id: \.self) { i in
                BarMark(
                    x: .value("Label", labels[i]),
                    y: .value("Pills", values[i])
                )
                .foregroundStyle(Color("AccentColor"))
                .cornerRadius(6)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

//
// MARK: - Labels
//
extension AnalyticsView {

    var dailyLabels: [String] {
        let count = summedDailyLast7.count
        return (0..<count).map { i in
            let daysAgo = count - 1 - i
            return daysAgo == 0 ? "Today" : "\(daysAgo)d"
        }
    }

    var weeklyLabels: [String] {
        ["W1", "W2", "W3", "W4"]
    }

    var monthlyLabels: [String] {
        (1...12).map { "M\($0)" }
    }
}

//
// MARK: - Aggregation Calculations
//
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

    var expectedPillsForCurrentRange: Int {
        let perDay = bottlesForUser.reduce(0) { sum, bottle in
            let doses = bottle.frequency == .onceDaily ? 1 :
                        bottle.frequency == .twiceDaily ? 2 : 3
            return sum + doses * bottle.dosageAmount
        }

        switch selectedRange {
        case .week: return perDay * 7
        case .month: return perDay * 28
        case .year: return perDay * 28 * 7
        }
    }

    var summedDailyLast7: [Int] {
        sumArrays(bottlesForUser.map { $0.dailyLast7 }, maxLength: 7)
    }

    var summedWeeklyLast4: [Int] {
        sumArrays(bottlesForUser.map { $0.weeklyLast4 }, maxLength: 4)
    }

    var summedMonthlyLast12: [Int] {
        sumArrays(bottlesForUser.map { $0.monthlyLast12 }, maxLength: 12)
    }

    func sumArrays(_ arrays: [[Int]], maxLength: Int) -> [Int] {
        var result = Array(repeating: 0, count: maxLength)
        for arr in arrays {
            let offset = maxLength - arr.count
            for (i, v) in arr.enumerated() {
                result[offset + i] += v
            }
        }
        return result
    }
}
