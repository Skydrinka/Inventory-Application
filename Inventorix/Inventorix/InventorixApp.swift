//
//  InventorixApp.swift
//  Inventorix
//
//  Created by Nikitas Kaouslides on 18/05/2024.
//

import SwiftUI

@main
struct InventorixApp: App {
    let persistenceController = PersistenceController.shared

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
}
