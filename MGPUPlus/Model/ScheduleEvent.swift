import Foundation
import SwiftData

@Model
final class ScheduleEvent: Identifiable {
    var id: UUID
    var remoteID: String
    var title: String
    var startAt: Date
    var endAt: Date
    var teacher: String
    var room: String
    var groupName: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        remoteID: String,
        title: String,
        startAt: Date,
        endAt: Date,
        teacher: String,
        room: String,
        groupName: String,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.remoteID = remoteID
        self.title = title
        self.startAt = startAt
        self.endAt = endAt
        self.teacher = teacher
        self.room = room
        self.groupName = groupName
        self.updatedAt = updatedAt
    }
}
