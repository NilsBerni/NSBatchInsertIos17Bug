//
//  CoreDataTestApp.swift
//  CoreDataTest
//
//  Created by Nils Bernschneider on 29.08.23.
//

import SwiftUI

@main
struct CoreDataTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
