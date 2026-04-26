import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedFaculty") private var selectedFacultyStorage: String = ""
    @AppStorage("selectedGroup") private var selectedGroupStorage: String = ""
    @AppStorage("selectedGroupId") private var selectedGroupIdStorage: Int = 0

    @State private var institutes: [CatalogInstitute] = []
    @State private var selectedFaculty: String = ""
    @State private var selectedGroup: String = ""
    @State private var selectedGroupId: Int = 0
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let catalogService = CatalogService()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("onboarding.title")
                .font(.largeTitle.bold())
                .foregroundStyle(.mcuRed)

            Text("onboarding.subtitle")
                .font(.callout)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            if isLoading && institutes.isEmpty {
                ProgressView("onboarding.loading")
                    .tint(.mcuRed)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let errorMessage, institutes.isEmpty {
                ContentUnavailableView {
                    Label("onboarding.error.title", systemImage: "building.2")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("onboarding.retry") {
                        _Concurrency.Task {
                            await loadCatalog()
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.faculty")
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Picker("onboarding.faculty", selection: $selectedFaculty) {
                        ForEach(institutes) { faculty in
                            Text(faculty.name).tag(faculty.name)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(selectionBackgroundColor, in: RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.group")
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Picker("onboarding.group", selection: $selectedGroupId) {
                        ForEach(availableGroups) { group in
                            Text(group.name).tag(group.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(selectionBackgroundColor, in: RoundedRectangle(cornerRadius: 10))
                }
            }

            Spacer(minLength: 0)

            Button(action: saveProfile, label: {
                Text("onboarding.continue")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .label))
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.mcuRed.opacity(0.55), in: .rect(cornerRadius: 10))
            })
        }
        .padding(20)
        .background(Color.appDarkGroupedBackground)
        .task {
            guard institutes.isEmpty, !isLoading else { return }
            await loadCatalog()
        }
        .onChange(of: selectedFaculty, initial: false) { _, _ in
            if let firstGroup = availableGroups.first {
                selectedGroupId = firstGroup.id
                selectedGroup = firstGroup.name
            } else {
                selectedGroupId = 0
                selectedGroup = ""
            }
        }
        .onChange(of: selectedGroupId, initial: false) { _, newValue in
            selectedGroup = availableGroups.first(where: { $0.id == newValue })?.name ?? ""
        }
    }

    private var availableGroups: [CatalogGroup] {
        institutes.first(where: { $0.name == selectedFaculty })?.groups ?? []
    }

    private func saveProfile() {
        selectedFacultyStorage = selectedFaculty
        selectedGroupStorage = selectedGroup
        selectedGroupIdStorage = selectedGroupId
        dismiss()
    }

    private var selectionBackgroundColor: Color {
        colorScheme == .dark ? Color.appDarkCardBackground : .mcuLightGrey.opacity(0.28)
    }

    @MainActor
    private func loadCatalog() async {
        isLoading = true
        defer { isLoading = false }

        do {
            institutes = try await catalogService.fetchCatalog()
            errorMessage = nil
            applyStoredSelection()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyStoredSelection() {
        guard !institutes.isEmpty else { return }

        let storedFaculty = UserDefaults.standard.string(forKey: "selectedFaculty") ?? ""
        let storedGroupId = UserDefaults.standard.integer(forKey: "selectedGroupId")
        let storedFacultyExists = institutes.contains(where: { $0.name == storedFaculty })
        let fallbackFaculty = institutes.first?.name ?? ""
        selectedFaculty = storedFacultyExists ? storedFaculty : fallbackFaculty

        if let selectedInstitute = institutes.first(where: { $0.name == selectedFaculty }) {
            if let storedGroup = selectedInstitute.groups.first(where: { $0.id == storedGroupId }) {
                selectedGroupId = storedGroup.id
                selectedGroup = storedGroup.name
            } else if let firstGroup = selectedInstitute.groups.first {
                selectedGroupId = firstGroup.id
                selectedGroup = firstGroup.name
            }
        }
    }
}

#Preview {
    OnboardingView()
}
