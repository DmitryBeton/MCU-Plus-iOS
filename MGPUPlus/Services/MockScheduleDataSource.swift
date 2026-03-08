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
        let schedule = try JSONDecoder().decode(MockCalendarDTO.self, from: data)

        let targetDate = Self.dateOnlyFormatter.string(from: date)
        guard let day = schedule.calendar.first(where: { $0.date == targetDate }) else {
            return []
        }

        return day.lessons.compactMap { lesson in
            guard let startAt = makeDate(dateString: day.date, timeString: lesson.startTime) else {
                return nil
            }
            guard let endAt = makeDate(dateString: day.date, timeString: lesson.endTime) else {
                return nil
            }

            return ScheduleDTO(
                id: lesson.id,
                title: lesson.title,
                startAt: startAt,
                endAt: endAt,
                teacher: lesson.teacher,
                room: lesson.room,
                groupName: lesson.groupName,
                academicStatus: ScheduleAcademicStatus(rawValue: lesson.academicStatus) ?? .active
            )
        }
    }

    private func makeDate(dateString: String, timeString: String) -> Date? {
        Self.dateTimeFormatter.date(from: "\(dateString) \(timeString)")
    }

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

private struct MockCalendarDTO: Decodable {
    let calendar: [MockDayScheduleDTO]
}

private struct MockDayScheduleDTO: Decodable {
    let date: String
    let lessons: [MockLessonDTO]
}

private struct MockLessonDTO: Decodable {
    let id: String
    let title: String
    let startTime: String
    let endTime: String
    let teacher: String
    let room: String
    let groupName: String
    let academicStatus: String
}
