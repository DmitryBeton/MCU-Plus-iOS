//
//  MGPUPlusApp.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI
import SwiftData

@main
struct MGPUPlusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}
