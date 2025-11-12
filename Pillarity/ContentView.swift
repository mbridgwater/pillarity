//
//  ContentView.swift
//  Pillarity
//
//  Created by Missy Bridgwater on 11/11/25.
//

import SwiftUI
import SwiftData
import AcaiaSDK

struct ContentView: View {
    // modelContext gives you access to the SwiftData “database session” for saving/deleting
    @Environment(\.modelContext) private var modelContext
    // @Query automatically fetches all Item objects from the SwiftData store into an array.
    @Query private var items: [Item]

    var body: some View {
        /*
         This creates:
            * A sidebar list of all stored Items.
            * A detail area (right-hand side) that shows the selected item’s timestamp.
            * Toolbar buttons for adding (+) and editing items.
         */
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    // Creates a new Item (timestamp = now) and adds it to the SwiftData database.
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    // Removes items that the user swipes to delete in the list.
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// Sets up an in-memory SwiftData store so Xcode’s canvas preview works without saving data permanently.
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
