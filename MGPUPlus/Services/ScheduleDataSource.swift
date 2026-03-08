import Foundation

struct ScheduleDTO {
    let id: String
    let title: String
    let startAt: Date
    let endAt: Date
    let teacher: String
    let room: String
    let groupName: String
}

protocol ScheduleDataSource {
    func fetchSchedule(for date: Date) async throws -> [ScheduleDTO]
}

enum ScheduleDataSourceError: LocalizedError {
    case mockFileNotFound

    var errorDescription: String? {
        switch self {
        case .mockFileNotFound:
            return "Mock schedule JSON not found in bundle"
        }
    }
}
