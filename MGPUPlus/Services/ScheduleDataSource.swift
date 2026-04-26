import Foundation

enum ScheduleAcademicStatus: String {
    case active
    case cancelled
    case replaced
    case online
}

struct ScheduleDTO {
    let id: String
    let title: String
    let startAt: Date
    let endAt: Date
    let teacher: String
    let room: String
    let facultyName: String
    let groupName: String
    let academicStatus: ScheduleAcademicStatus
}

protocol ScheduleDataSource {
    func fetchSchedule(for date: Date, groupId: Int) async throws -> [ScheduleDTO]
}

enum ScheduleDataSourceError: LocalizedError {
    case mockFileNotFound
    case invalidResponse
    case invalidURL
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .mockFileNotFound:
            return "Mock schedule JSON not found in bundle"
        case .invalidResponse:
            return "Invalid schedule API response"
        case .invalidURL:
            return "Invalid schedule API URL"
        case .decodingFailed:
            return "Failed to decode schedule API response"
        }
    }
}
