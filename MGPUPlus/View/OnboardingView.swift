import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedFaculty") private var selectedFacultyStorage: String = ""
    @AppStorage("selectedGroup") private var selectedGroupStorage: String = ""

    @State private var selectedFaculty: String
    @State private var selectedGroup: String

    init() {
        let defaultFaculty = StudyCatalog.faculties.first?.name ?? ""
        let storedFaculty = UserDefaults.standard.string(forKey: "selectedFaculty") ?? ""
        let initialFaculty = StudyCatalog.faculties.contains(where: { $0.name == storedFaculty }) ? storedFaculty : defaultFaculty
        let availableGroups = StudyCatalog.groups(for: initialFaculty)
        let storedGroup = UserDefaults.standard.string(forKey: "selectedGroup") ?? ""
        let initialGroup = availableGroups.contains(storedGroup) ? storedGroup : (availableGroups.first ?? "")

        _selectedFaculty = State(initialValue: initialFaculty)
        _selectedGroup = State(initialValue: initialGroup)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("onboarding.title")
                .font(.largeTitle.bold())
                .foregroundStyle(.mcuRed)

            Text("onboarding.subtitle")
                .font(.callout)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            VStack(alignment: .leading, spacing: 8) {
                Text("onboarding.faculty")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))

                Picker("onboarding.faculty", selection: $selectedFaculty) {
                    ForEach(StudyCatalog.faculties) { faculty in
                        Text(faculty.name).tag(faculty.name)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("onboarding.group")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))

                Picker("onboarding.group", selection: $selectedGroup) {
                    ForEach(availableGroups, id: \.self) { group in
                        Text(group).tag(group)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
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
        .background(Color(uiColor: .systemGroupedBackground))
        .onChange(of: selectedFaculty, initial: false) { _, _ in
            if !availableGroups.contains(selectedGroup) {
                selectedGroup = availableGroups.first ?? ""
            }
        }
    }

    private var availableGroups: [String] {
        StudyCatalog.groups(for: selectedFaculty)
    }

    private func saveProfile() {
        selectedFacultyStorage = selectedFaculty
        selectedGroupStorage = selectedGroup
        dismiss()
    }
}

#Preview {
    OnboardingView()
}
