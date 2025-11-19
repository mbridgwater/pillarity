//
//  HomeView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    // All bottles (each one already references a Pill via `type`)
    @Query(sort: \PillBottle.timestamp, order: .reverse) private var bottles: [PillBottle]

    @State private var showAddFlow = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Medications")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    if bottles.isEmpty {
                        Text("No pill bottles added yet.")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(bottles) { bottle in
                                PillBottleCard(bottle: bottle)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Pillarity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    showAddFlow = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            .navigationDestination(isPresented: $showAddFlow) {
                ConnectScaleView {
                    showAddFlow = false
                }
            }
//                // + button to start the “add new bottle” flow
//                NavigationLink {
//                    ConnectScaleView()
//                } label: {
//                    Image(systemName: "plus")
//                        .font(.title2)
//                }
            }
        }
    }
