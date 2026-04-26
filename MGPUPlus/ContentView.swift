//
//  ContentView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI

struct ContentView: View {
    private enum TabSelection: Hashable {
        case news
        case schedule
        case settings
    }

    @AppStorage("selectedFaculty") private var selectedFaculty: String = ""
    @AppStorage("selectedGroup") private var selectedGroup: String = ""
    @AppStorage("selectedGroupId") private var selectedGroupId: Int = 0
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("appTheme") private var appTheme: String = "light"
    @State private var selectedTab: TabSelection = .schedule

    var body: some View {
        Group {
            if hasSelectedProfile {
                TabView(selection: $selectedTab) {
                    NewsView()
                        .tabItem {
                            Label("tab.news", systemImage: "newspaper")
                        }
                        .tag(TabSelection.news)

                    Home(selectedFaculty: selectedFaculty, selectedGroup: selectedGroup, selectedGroupId: selectedGroupId)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.appDarkGroupedBackground)
                        .tabItem {
                            Label("tab.schedule", systemImage: "calendar")
                        }
                        .tag(TabSelection.schedule)

                    SettingsView()
                        .tabItem {
                            Label("tab.settings", systemImage: "gearshape")
                        }
                        .tag(TabSelection.settings)
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
        !selectedFaculty.isEmpty && !selectedGroup.isEmpty && selectedGroupId > 0
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
