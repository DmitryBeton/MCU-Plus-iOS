//
//  MGPUPlusApp.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI
//import CoreData
import SwiftData

@main
struct MGPUPlusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .modelContainer(for: Task.self)
    }
}
