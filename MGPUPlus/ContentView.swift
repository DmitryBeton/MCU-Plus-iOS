//
//  ContentView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI

struct ContentView: View {
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
