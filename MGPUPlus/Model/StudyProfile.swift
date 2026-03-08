import Foundation

struct FacultyProfile: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let logoAssetName: String
    let groups: [String]
}

enum StudyCatalog {
    static let faculties: [FacultyProfile] = [
        FacultyProfile(
            name: "Институт среднего профессионального образования им. К.Д. Ушинского",
            logoAssetName: "UshinskyCollege1Logo",
            groups: ["СПО-11", "СПО-12", "СПО-13"]
        ),
        FacultyProfile(
            name: "Институт педагогики и психологии образования",
            logoAssetName: "EducationPsychology1Logo",
            groups: ["ППО-11", "ППО-12", "ППО-13"]
        ),
        FacultyProfile(
            name: "Институт права и управления",
            logoAssetName: "LawManagementLogo",
            groups: ["ПУ-21", "ПУ-22"]
        ),
        FacultyProfile(
            name: "Институт цифрового образования",
            logoAssetName: "DigitalEducation1Logo",
            groups: ["ИО-21", "ИО-22", "ИО-23"]
        ),
        FacultyProfile(
            name: "Институт культуры и искусств",
            logoAssetName: "CultureArts1Logo",
            groups: ["КИ-31", "КИ-32"]
        ),
        FacultyProfile(
            name: "Институт содержания, методов и технологий образования",
            logoAssetName: "EducationMethodsTech1Logo",
            groups: ["МТО-41", "МТО-42"]
        ),
        FacultyProfile(
            name: "Институт иностранных языков",
            logoAssetName: "ForeignLanguagesLogo",
            groups: ["ИЯ-31", "ИЯ-32", "ИЯ-33"]
        ),
        FacultyProfile(
            name: "Институт естествознания и спортивных технологий",
            logoAssetName: "NaturalScienceSportTechLogo",
            groups: ["ЕСТ-21", "ЕСТ-22"]
        ),
        FacultyProfile(
            name: "Институт гуманитарных наук",
            logoAssetName: "HumanitiesLogo",
            groups: ["ГН-11", "ГН-12"]
        ),
        FacultyProfile(
            name: "НИИ урбанистики и глобального образования",
            logoAssetName: "UrbanGlobalEducationResearchLogo",
            groups: ["УРБ-51", "УРБ-52"]
        )
    ]

    static func groups(for faculty: String) -> [String] {
        faculties.first(where: { $0.name == faculty })?.groups ?? []
    }

    static func logoAssetName(for faculty: String) -> String? {
        faculties.first(where: { $0.name == faculty })?.logoAssetName
    }
}
