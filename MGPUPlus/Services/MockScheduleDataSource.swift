import Foundation

struct MockScheduleDataSource: ScheduleDataSource {
    private let resourceName: String

    init(resourceName: String = "schedule_mock") {
        self.resourceName = resourceName
    }

    func fetchSchedule(for date: Date) async throws -> [ScheduleDTO] {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw ScheduleDataSourceError.mockFileNotFound
        }

        let data = try Data(contentsOf: url)
        let templates = try JSONDecoder().decode([ScheduleTemplateDTO].self, from: data)

        return templates.compactMap { template in
            guard let startAt = makeDate(date: date, hour: template.startHour, minute: template.startMinute) else {
                return nil
            }

            guard let endAt = Calendar.current.date(byAdding: .minute, value: template.durationMinutes, to: startAt) else {
                return nil
            }

            let dayStamp = Self.dayStampFormatter.string(from: date)

            return ScheduleDTO(
                id: "\(template.templateID)-\(dayStamp)",
                title: template.title,
                startAt: startAt,
                endAt: endAt,
                teacher: template.teacher,
                room: template.room,
                groupName: template.groupName
            )
        }
    }

    private func makeDate(date: Date, hour: Int, minute: Int) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }

    private static let dayStampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}

private struct ScheduleTemplateDTO: Decodable {
    let templateID: String
    let title: String
    let startHour: Int
    let startMinute: Int
    let durationMinutes: Int
    let teacher: String
    let room: String
    let groupName: String
}
