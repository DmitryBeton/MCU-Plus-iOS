//
//  Home.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 27.02.2026.
//

import SwiftUI
import SwiftData

struct Home: View {
    @Environment(\.modelContext) private var modelContext
    // Task Manager Properties
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var suppressWeekIndexObserver: Bool = false
    @State private var createNewTask: Bool = false
    // Animation Namespace
    @Namespace private var animation
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HeaderView()

            ScrollView(.vertical) {
                VStack {
                    // Tasks View
                    TasksView(currentDate: $currentDate)
                }
                .hSpacing(.center)
                .vSpacing(.center)
            }
            .scrollIndicators(.hidden)
            .simultaneousGesture(daySwipeGesture)
        })
        .vSpacing(.top)
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: {
                createNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 55, height: 55)
                    .background(.mcuRed.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(15)
        })
        .onAppear(perform: {
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()

                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }

                weekSlider.append(currentWeek)

                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
        })
        .task(id: currentDate) {
            await ScheduleSyncService.sync(for: currentDate, context: modelContext)
        }
        .sheet(isPresented: $createNewTask, content: {
            NewTaskView()
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
                .presentationBackground(.mcuBackground)
        })
    }

    // Header View
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack(spacing: 5) {
                Text(currentDate.format("MMMM"))
                    .foregroundStyle(.mcuRed)

                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
            }
            .font(.title.bold())

            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)

            // Week Slider
            TabView(selection: $currentWeekIndex) {
                ForEach(weekSlider.indices, id: \.self) { index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
        }
        .hSpacing(.leading)
        .overlay(alignment: .topTrailing, content: {
            Button(action: {}, label: {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(.circle)
            })
        })
        .padding(15)
        .background(.white)
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            if suppressWeekIndexObserver {
                return
            }
            
            // Creating When it reaches first/last Page
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true

            }
        }
    }

    // Week View
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)

                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                Circle()
                                    .fill(.mcuRed)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }

                            // Indicator to Show, Which is Today's Date
                            if day.date.isToday {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: .circle)

                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
                    // Updating Current Date
                    withAnimation(.snappy) {
                        currentDate = day.date
                    }
                }
            }
        }
        .background {
            GeometryReader {
                let minX = $0.frame(in: .global).minX

                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        // When the Offset reaches 15 and if the createWeek is toggled then Simply generating next set of week
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }

    func paginateWeek() {
        // SafeCheck
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                // Inserting New Week at 0th Index and Removing Last Array Item
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }

            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                // Appending New Week at Last Index and Removing First Array Item
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeFirst()
                currentWeekIndex = weekSlider.count - 2
            }

        }
    }
    
    private var daySwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                guard abs(vertical) < 50 else {
                    return
                }

                guard abs(horizontal) > 50, abs(horizontal) > abs(vertical) * 1.5 else {
                    return
                }
                
                if horizontal < 0 {
                    moveDay(by: 1)
                } else {
                    moveDay(by: -1)
                }
            }
    }
    
    private func moveDay(by value: Int) {
        guard let nextDate = Calendar.current.date(byAdding: .day, value: value, to: currentDate) else {
            return
        }
        
        if weekSlider.firstIndex(where: { week in
            week.contains(where: { isSameDate($0.date, nextDate) })
        }) == nil {
            paginateWeekManually(direction: value)
        }
        
        guard let targetWeekIndex = weekSlider.firstIndex(where: { week in
            week.contains(where: { isSameDate($0.date, nextDate) })
        }) else {
            return
        }

        withAnimation(.snappy) {
            currentDate = nextDate
            setCurrentWeekIndex(targetWeekIndex)
        }
    }
    
    private func paginateWeekManually(direction: Int) {
        guard !weekSlider.isEmpty else { return }
        
        if direction < 0 {
            setCurrentWeekIndex(0)
            paginateWeek()
        } else if direction > 0 {
            setCurrentWeekIndex(weekSlider.count - 1)
            paginateWeek()
        }
        
        createWeek = false
    }
    
    private func setCurrentWeekIndex(_ index: Int) {
        suppressWeekIndexObserver = true
        currentWeekIndex = index
        suppressWeekIndexObserver = false
    }
}

#Preview {
    ContentView()
}
