import Foundation

enum StudyCatalog {
    private static let logoMap: [String: String] = [
        "Институт среднего профессионального образования им. К.Д. Ушинского": "UshinskyCollege1Logo",
        "Институт педагогики и психологии образования": "EducationPsychology1Logo",
        "Институт права и управления": "LawManagementLogo",
        "Институт цифрового образования": "DigitalEducation1Logo",
        "Институт культуры и искусств": "CultureArts1Logo",
        "Институт содержания, методов и технологий образования": "EducationMethodsTech1Logo",
        "Институт иностранных языков": "ForeignLanguagesLogo",
        "Институт естествознания и спортивных технологий": "NaturalScienceSportTechLogo",
        "Институт гуманитарных наук": "HumanitiesLogo",
        "НИИ урбанистики и глобального образования": "UrbanGlobalEducationResearchLogo"
    ]

    static func logoAssetName(for faculty: String) -> String? {
        logoMap[faculty]
    }
}
