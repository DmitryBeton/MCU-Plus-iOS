import SwiftUI

struct ScheduleEventRowView: View {
    let event: ScheduleEvent
    
    private enum LessonStatus {
        case current
        case upcoming
        case finished
        case scheduled
    }

    var body: some View {
        let startTime = event.startAt.format("HH:mm")
        let endTime = event.endAt.format("HH:mm")

        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorFillColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .stroke(status == .current ? .mcuRed : .clear, lineWidth: status == .current ? 2 : 0)
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(event.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    
                    Spacer(minLength: 8)

                    if showStatusChip {
                        Text(statusTitle)
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

                Text("\(event.teacher) · \(event.room)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(15)
            .hSpacing(.leading)
            .background(cardBackgroundColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .opacity(status == .finished ? 0.6 : 1)
        }
    }
    
    private var status: LessonStatus {
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
        }
    }
    
    private var statusTitle: String {
        switch status {
        case .current:
            return "Сейчас"
        case .upcoming:
            return "Скоро"
        case .finished:
            return "Завершено"
        case .scheduled:
            return ""
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
        }
    }

    private var showStatusChip: Bool {
        status != .scheduled
    }
}
