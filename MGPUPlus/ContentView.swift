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
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("appTheme") private var appTheme: String = "light"

    var body: some View {
        Group {
            if hasSelectedProfile {
                TabView {
                    Tab("tab.schedule", systemImage: "calendar") {
                        Home(selectedFaculty: selectedFaculty, selectedGroup: selectedGroup)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemGroupedBackground))
                    }

                    Tab("tab.settings", systemImage: "gearshape") {
                        SettingsView()
                    }
                }
                .tint(.mcuRed)
            } else {
                OnboardingView()
            }
        }
        .environment(\.locale, Locale(identifier: appLanguage))
        .preferredColorScheme(preferredColorScheme)
    }

    private var hasSelectedProfile: Bool {
        !selectedFaculty.isEmpty && !selectedGroup.isEmpty
    }

    private var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil
        }
    }
}
