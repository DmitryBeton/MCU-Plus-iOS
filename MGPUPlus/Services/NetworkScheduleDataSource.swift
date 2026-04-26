import Foundation

struct NetworkScheduleDataSource: ScheduleDataSource {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchSchedule(for date: Date, groupId: Int) async throws -> [ScheduleDTO] {
        guard groupId > 0 else { return [] }
        guard let baseURL = BackendConfiguration.baseURL else {
            throw ScheduleDataSourceError.invalidURL
        }

        let from = Self.dateFormatter.string(from: date)
        let to = Self.dateFormatter.string(from: date)

        guard var components = URLComponents(url: baseURL.appending(path: "/api/v1/schedule/"), resolvingAgainstBaseURL: false) else {
            throw ScheduleDataSourceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "groupId", value: "\(groupId)"),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to)
        ]

        guard let url = components.url else {
            throw ScheduleDataSourceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw ScheduleDataSourceError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let payload = try decoder.decode(ScheduleResponseDTO.self, from: data)
            return payload.items.map { item in
                ScheduleDTO(
                    id: String(item.id),
                    title: item.title,
                    startAt: item.startAt,
                    endAt: item.endAt,
                    teacher: item.teacher,
                    room: item.room,
                    facultyName: payload.group.instituteName,
                    groupName: payload.group.name,
                    academicStatus: ScheduleAcademicStatus(rawValue: item.status) ?? .active
                )
            }
        } catch {
            throw ScheduleDataSourceError.decodingFailed
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return formatter
    }()
}

private struct ScheduleResponseDTO: Decodable {
    let group: ScheduleGroupDTO
    let items: [ScheduleItemDTO]
}

private struct ScheduleGroupDTO: Decodable {
    let id: Int
    let name: String
    let course: Int
    let instituteId: Int
    let instituteName: String
}

private struct ScheduleItemDTO: Decodable {
    let id: Int
    let date: String
    let title: String
    let teacher: String
    let room: String
    let startAt: Date
    let endAt: Date
    let status: String
    let comment: String
}
