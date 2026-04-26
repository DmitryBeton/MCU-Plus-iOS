import Foundation

enum BackendConfiguration {
    static let backendURLKey = "backendBaseURL"
    static let defaultBaseURLString = "http://192.168.1.4:8000"

    static var baseURLString: String {
        let storedValue = UserDefaults.standard.string(forKey: backendURLKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let storedValue, !storedValue.isEmpty {
            return storedValue
        }

        return defaultBaseURLString
    }

    static var baseURL: URL? {
        URL(string: baseURLString)
    }
}
