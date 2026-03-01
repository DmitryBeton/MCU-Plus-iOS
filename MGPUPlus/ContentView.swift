//
//  ContentView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            Tab("tab.schedule", systemImage: "calendar") {
                Home()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.mcuBackground)
                    .preferredColorScheme(.light)
            }
//            Tab("tab.settings", systemImage: "gearshape") {
//            }
        }
        .tint(.mcuRed)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
