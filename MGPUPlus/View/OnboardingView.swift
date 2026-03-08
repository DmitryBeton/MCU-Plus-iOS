import SwiftUI

struct OnboardingView: View {
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
            Text("Добро пожаловать")
                .font(.largeTitle.bold())
                .foregroundStyle(.mcuRed)

            Text("Выбери свой факультет и группу, чтобы видеть персональное расписание.")
                .font(.callout)
                .foregroundStyle(.gray)

            VStack(alignment: .leading, spacing: 8) {
                Text("Факультет")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Picker("Факультет", selection: $selectedFaculty) {
                    ForEach(StudyCatalog.faculties) { faculty in
                        Text(faculty.name).tag(faculty.name)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Группа")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Picker("Группа", selection: $selectedGroup) {
                    ForEach(availableGroups, id: \.self) { group in
                        Text(group).tag(group)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 10))
            }

            Spacer(minLength: 0)

            Button(action: saveProfile, label: {
                Text("Продолжить")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.mcuRed.opacity(0.55), in: .rect(cornerRadius: 10))
            })
        }
        .padding(20)
        .background(.mcuBackground)
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
    }
}

#Preview {
    OnboardingView()
}
