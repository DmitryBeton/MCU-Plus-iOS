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
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

            let predicate = #Predicate<ScheduleEvent> {
                $0.startAt >= startOfDay && $0.startAt < endOfDay
            }
            let descriptor = FetchDescriptor<ScheduleEvent>(predicate: predicate)
            let localEvents = try context.fetch(descriptor)
            var localByRemoteID = Dictionary(uniqueKeysWithValues: localEvents.map { ($0.remoteID, $0) })
            var receivedRemoteIDs = Set<String>()

            for remote in remoteEvents {
                receivedRemoteIDs.insert(remote.id)

                if let local = localByRemoteID[remote.id] {
                    local.title = remote.title
                    local.startAt = remote.startAt
                    local.endAt = remote.endAt
                    local.teacher = remote.teacher
                    local.room = remote.room
                    local.groupName = remote.groupName
                    local.academicStatus = remote.academicStatus
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
                        academicStatusRaw: remote.academicStatus.rawValue,
                        updatedAt: Date()
                    )
                    context.insert(newEvent)
                    localByRemoteID[remote.id] = newEvent
                }
            }

            for local in localEvents where !receivedRemoteIDs.contains(local.remoteID) {
                context.delete(local)
            }

            try context.save()
        } catch {
            print("Schedule sync failed: \(error.localizedDescription)")
        }
    }
}
