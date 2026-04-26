import Foundation

struct CatalogInstitute: Identifiable, Hashable {
    let id: Int
    let name: String
    let shortName: String
    let logo: String
    let groups: [CatalogGroup]
}

struct CatalogGroup: Identifiable, Hashable {
    let id: Int
    let name: String
    let course: Int
}

struct CatalogService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCatalog() async throws -> [CatalogInstitute] {
        guard let baseURL = BackendConfiguration.baseURL else {
            throw CatalogServiceError.invalidURL
        }

        let url = baseURL.appending(path: "/api/v1/catalog/")
        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw CatalogServiceError.invalidResponse
        }

        let decoder = JSONDecoder()
        let payload = try decoder.decode(CatalogResponseDTO.self, from: data)
        return payload.institutes.map { institute in
            CatalogInstitute(
                id: institute.id,
                name: institute.name,
                shortName: institute.shortName,
                logo: institute.logo,
                groups: institute.groups.map {
                    CatalogGroup(id: $0.id, name: $0.name, course: $0.course)
                }
            )
        }
    }
}

enum CatalogServiceError: LocalizedError {
    case invalidResponse
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return NSLocalizedString("onboarding.error.load", comment: "")
        case .invalidURL:
            return NSLocalizedString("settings.backend.error", comment: "")
        }
    }
}

private struct CatalogResponseDTO: Decodable {
    let institutes: [CatalogInstituteDTO]
}

private struct CatalogInstituteDTO: Decodable {
    let id: Int
    let name: String
    let shortName: String
    let logo: String
    let groups: [CatalogGroupDTO]
}

private struct CatalogGroupDTO: Decodable {
    let id: Int
    let name: String
    let course: Int
}
