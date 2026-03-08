import Foundation
import SwiftData

@MainActor
enum ScheduleSyncService {
    static func sync(
        for date: Date,
        context: ModelContext
    ) async {
        await sync(for: date, context: context, dataSource: MockScheduleDataSource())
    }

    static func sync(
        for date: Date,
        context: ModelContext,
        dataSource: ScheduleDataSource
    ) async {
        do {
            let remoteEvents = try await dataSource.fetchSchedule(for: date)
            let descriptor = FetchDescriptor<ScheduleEvent>()
            let localEvents = try context.fetch(descriptor)
            var localByRemoteID = Dictionary(uniqueKeysWithValues: localEvents.map { ($0.remoteID, $0) })

            for remote in remoteEvents {
                if let local = localByRemoteID[remote.id] {
                    local.title = remote.title
                    local.startAt = remote.startAt
                    local.endAt = remote.endAt
                    local.teacher = remote.teacher
                    local.room = remote.room
                    local.groupName = remote.groupName
                    local.updatedAt = Date()
                } else {
                    let newEvent = ScheduleEvent(
                        remoteID: remote.id,
                        title: remote.title,
                        startAt: remote.startAt,
                        endAt: remote.endAt,
                        teacher: remote.teacher,
                        room: remote.room,
                        groupName: remote.groupName,
                        updatedAt: Date()
                    )
                    context.insert(newEvent)
                    localByRemoteID[remote.id] = newEvent
                }
            }

            try context.save()
        } catch {
            print("Schedule sync failed: \(error.localizedDescription)")
        }
    }
}
