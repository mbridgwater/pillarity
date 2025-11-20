import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    let currentUser: User

    @Query(sort: \PillBottle.createdAt, order: .reverse) private var allBottles: [PillBottle]

    var bottlesForUser: [PillBottle] {
        allBottles.filter { $0.owner == currentUser }
    }

    @State private var showAddFlow = false

    var body: some View {
        NavigationStack {
            // MAIN SCROLL CONTENT
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Top dashboard cards (fake data for now)
                    HStack(spacing: 16) {
                        DashboardCard.dosesTodayCard(for: bottlesForUser)
                        DashboardCard.nextDoseCard(for: bottlesForUser)
                    }
                    .padding(.horizontal)

                    // Header with pill-shaped Add button aligned to the right
                    HStack {
                        Text("My Medications")
                            .font(.title2)
                            .bold()

                        Spacer()

                        Button {
                            showAddFlow = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.headline)
                                Text("Add")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color("AccentColor"))
                            .clipShape(Capsule())
                            .shadow(radius: 3, y: 1)
                        }
                        .accessibilityLabel("Add Medication")
                    }
                    .padding(.horizontal)

                    if bottlesForUser.isEmpty {
                        Text("No pill bottles added yet.")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(bottlesForUser) { bottle in
                                PillBottleCard(bottle: bottle)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showAddFlow) {
                ConnectScaleView {
                    showAddFlow = false
                }
            }
        }
    }
}
