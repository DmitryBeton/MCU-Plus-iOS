//
//  TaskRowView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 28.02.2026.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: Task
    // Model Context
    @Environment(\.modelContext) private var context
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(Color(uiColor: .secondarySystemBackground).shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: .circle)
                .overlay {
                    Circle()
                        .frame(width: 50, height: 50)
                        .blendMode(.destinationOver)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                task.isCompleted.toggle()
                            }
                        }
                }

            VStack(alignment: .leading, spacing: 8, content: {
                Text(task.taskTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .label))

                Label(task.creationDate.format("hh:mm a"), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .label))
            })
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .strikethrough(task.isCompleted, pattern: .solid, color: Color(uiColor: .label))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15))
            .contextMenu {
                Button("task.delete", role: .destructive) {
                    // Deleting Task
                    context.delete(task)
                    try? context.save()
                }
            }
            .offset(y: -8)
        }
    }

    var indicatorColor: Color {
        if task.isCompleted {
            return .green
        }
        return task.creationDate.isSameHour ? .mcuRed : (task.creationDate.isPast ? .red : Color(uiColor: .label))
    }
}

#Preview {
    ContentView()
}
