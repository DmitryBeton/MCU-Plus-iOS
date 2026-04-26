import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") private var appLanguage: String = "ru"
    @AppStorage("appTheme") private var appTheme: String = "light"
    @AppStorage(BackendConfiguration.backendURLKey) private var backendBaseURL: String = BackendConfiguration.defaultBaseURLString

    @State private var showOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("settings.language.section") {
                    Picker("settings.language.title", selection: $appLanguage) {
                        Text("settings.language.russian").tag("ru")
                        Text("settings.language.english").tag("en")
                    }
                    .pickerStyle(.segmented)
                }

                Section("settings.theme.section") {
                    Picker("settings.theme.title", selection: $appTheme) {
                        Text("settings.theme.system").tag("system")
                        Text("settings.theme.light").tag("light")
                        Text("settings.theme.dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("settings.study.section") {
                    Button(action: {
                        showOnboarding = true
                    }, label: {
                        HStack {
                            Text("settings.study.change")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.gray)
                        }
                    })
                    .foregroundStyle(.primary)
                }

                Section("settings.backend.section") {
                    TextField("settings.backend.placeholder", text: $backendBaseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()

                    Text("settings.backend.hint")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("tab.settings")
            .scrollContentBackground(.hidden)
            .background(Color.appDarkGroupedBackground)
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
        }
        .background(Color.appDarkGroupedBackground)
    }
}

#Preview {
    SettingsView()
}
