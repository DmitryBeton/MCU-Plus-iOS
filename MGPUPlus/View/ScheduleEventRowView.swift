import SwiftUI

struct ScheduleEventRowView: View {
    let event: ScheduleEvent
    
    private enum LessonStatus {
        case current
        case upcoming
        case finished
        case scheduled
        case cancelled
        case replaced
        case online
    }

    var body: some View {
        let startTime = event.startAt.format("HH:mm")
        let endTime = event.endAt.format("HH:mm")

        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorFillColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(Color(uiColor: .secondarySystemBackground).shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .stroke(status == .current ? .mcuRed : .clear, lineWidth: status == .current ? 2 : 0)
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(event.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Spacer(minLength: 8)

                    if showStatusChip {
                        Text(statusKey)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(statusTextColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusBackgroundColor, in: Capsule())
                    }
                }

                Text("\(startTime) - \(endTime)")
                    .font(.caption)
                    .foregroundStyle(status == .current ? .mcuRed : .mcuGrey)
                    .strikethrough(status == .cancelled, pattern: .solid, color: .gray)

                Text("\(event.teacher) · \(event.room)")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            .padding(15)
            .hSpacing(.leading)
            .background(cardBackgroundColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .opacity(status == .finished ? 0.6 : 1)
        }
    }
    
    private var status: LessonStatus {
        switch event.academicStatus {
        case .cancelled:
            return .cancelled
        case .replaced:
            return .replaced
        case .online:
            return .online
        case .active:
            break
        }

        let now = Date()
        if now >= event.startAt && now < event.endAt {
            return .current
        }
        if now < event.startAt {
            if Calendar.current.isDate(event.startAt, inSameDayAs: now) {
                return .upcoming
            }
            return .scheduled
        }
        return .finished
    }
    
    private var indicatorFillColor: Color {
        switch status {
        case .current:
            return .mcuRed
        case .upcoming:
            return .mcuGrey
        case .finished:
            return .gray
        case .scheduled:
            return .mcuGrey
        case .cancelled:
            return .gray
        case .replaced:
            return .orange
        case .online:
            return .blue
        }
    }
    
    private var cardBackgroundColor: Color {
        switch status {
        case .current:
            return .mcuRed.opacity(0.18)
        case .upcoming:
            return .mcuLightGrey.opacity(0.4)
        case .finished:
            return .mcuLightGrey.opacity(0.25)
        case .scheduled:
            return .mcuLightGrey.opacity(0.4)
        case .cancelled:
            return .gray.opacity(0.14)
        case .replaced:
            return .orange.opacity(0.16)
        case .online:
            return .blue.opacity(0.14)
        }
    }
    
    private var statusKey: LocalizedStringKey {
        switch status {
        case .current:
            return "schedule.status.current"
        case .upcoming:
            return "schedule.status.upcoming"
        case .finished:
            return "schedule.status.finished"
        case .scheduled:
            return ""
        case .cancelled:
            return "schedule.status.cancelled"
        case .replaced:
            return "schedule.status.replaced"
        case .online:
            return "schedule.status.online"
        }
    }
    
    private var statusBackgroundColor: Color {
        switch status {
        case .current:
            return .mcuRed.opacity(0.2)
        case .upcoming:
            return .orange.opacity(0.2)
        case .finished:
            return .gray.opacity(0.2)
        case .scheduled:
            return .clear
        case .cancelled:
            return .gray.opacity(0.24)
        case .replaced:
            return .orange.opacity(0.24)
        case .online:
            return .blue.opacity(0.2)
        }
    }
    
    private var statusTextColor: Color {
        switch status {
        case .current:
            return .mcuRed
        case .upcoming:
            return .orange
        case .finished:
            return .gray
        case .scheduled:
            return .clear
        case .cancelled:
            return .gray
        case .replaced:
            return .orange
        case .online:
            return .blue
        }
    }

    private var showStatusChip: Bool {
        status != .scheduled
    }
}
