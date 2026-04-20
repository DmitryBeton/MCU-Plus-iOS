//
//  TasksView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 01.03.2026.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Binding var currentDate: Date
    let selectedGroup: String

    @Query private var tasks: [Task]
    @Query private var scheduleEvents: [ScheduleEvent]

    init(currentDate: Binding<Date>, selectedGroup: String) {
        self._currentDate = currentDate
        self.selectedGroup = selectedGroup

        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!

        let taskPredicate = #Predicate<Task> {
            $0.creationDate >= startOfDate && $0.creationDate < endOfDate
        }
        let taskSortDescriptor = [
            SortDescriptor(\Task.creationDate, order: .forward)
        ]
        self._tasks = Query(filter: taskPredicate, sort: taskSortDescriptor, animation: .snappy)

        let eventPredicate = #Predicate<ScheduleEvent> {
            $0.startAt >= startOfDate && $0.startAt < endOfDate && $0.groupName == selectedGroup
        }
        let eventSortDescriptor = [
            SortDescriptor(\ScheduleEvent.startAt, order: .forward)
        ]
        self._scheduleEvents = Query(filter: eventPredicate, sort: eventSortDescriptor, animation: .snappy)
    }

    var body: some View {
        let showSectionHeaders = !scheduleEvents.isEmpty && !tasks.isEmpty

        VStack(alignment: .leading, spacing: 20) {
            if !scheduleEvents.isEmpty {
                if showSectionHeaders {
                    Text("schedule.section")
                        .font(.headline)
                        .foregroundStyle(.mcuGrey)
                }

                ForEach(scheduleEvents) { event in
                    ScheduleEventRowView(event: event)
                        .background(alignment: .leading) {
                            if scheduleEvents.last?.id != event.id {
                                Rectangle()
                                    .foregroundStyle(Color(uiColor: .separator))
                                    .frame(width: 1)
                                    .offset(x: 8)
                                    .padding(.bottom, -20)
                            }
                        }
                }
            }

            if !tasks.isEmpty {
                if showSectionHeaders {
                    Text("task.section")
                        .font(.headline)
                        .foregroundStyle(.mcuGrey)
                }

                VStack(alignment: .leading, spacing: 35) {
                    ForEach(tasks) { task in
                        TaskRowView(task: task)
                            .background(alignment: .leading) {
                                if tasks.last?.id != task.id {
                                    Rectangle()
                                        .foregroundStyle(Color(uiColor: .separator))
                                        .frame(width: 1)
                                        .offset(x: 8)
                                        .padding(.bottom, -35)
                                }
                            }
                    }
                }
            }
        }
        .padding([.vertical, .leading], 15)
        .padding(.top, 15)
        .overlay {
            if tasks.isEmpty && scheduleEvents.isEmpty {
                Text("schedule.empty")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .frame(width: 170)
            }
        }
    }
}

#Preview {
    ContentView()
}
