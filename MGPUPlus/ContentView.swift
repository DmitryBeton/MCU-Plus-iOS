//
//  ContentView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedFaculty") private var selectedFaculty: String = ""
    @AppStorage("selectedGroup") private var selectedGroup: String = ""

    var body: some View {
        if hasSelectedProfile {
            TabView {
                Tab("tab.schedule", systemImage: "calendar") {
                    Home(selectedFaculty: selectedFaculty, selectedGroup: selectedGroup)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.mcuBackground)
                        .preferredColorScheme(.light)
                }
            }
            .tint(.mcuRed)
        } else {
            OnboardingView()
        }
    }

    private var hasSelectedProfile: Bool {
        !selectedFaculty.isEmpty && !selectedGroup.isEmpty
    }
}
