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
    @AppStorage("appLanguage") private var appLanguage: String = "ru"

    let selectedFaculty: String
    let selectedGroup: String

    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex: Int = 1
    @State private var createWeek: Bool = false
    @State private var suppressWeekIndexObserver: Bool = false
    @State private var createNewTask: Bool = false
    @State private var showProfileEditor: Bool = false

    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HeaderView()

            ScrollView(.vertical) {
                VStack {
                    TasksView(currentDate: $currentDate, selectedGroup: selectedGroup)
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
        .task(id: "\(selectedFaculty)-\(selectedGroup)-\(Calendar.current.startOfDay(for: currentDate).timeIntervalSince1970)") {
            await ScheduleSyncService.sync(
                for: currentDate,
                facultyName: selectedFaculty,
                groupName: selectedGroup,
                context: modelContext
            )
        }
        .sheet(isPresented: $createNewTask, content: {
            NewTaskView()
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
                .presentationBackground(.mcuBackground)
        })
        .sheet(isPresented: $showProfileEditor) {
            OnboardingView()
        }
    }

    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(currentDate.format("MMMM", locale: appLocale))
                    .foregroundStyle(.mcuRed)

                Text(currentDate.format("yyyy", locale: appLocale))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            .font(.title.bold())

            Text(currentDate.localizedFullDate(locale: appLocale))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

            Text("\(selectedFaculty) · \(selectedGroup)")
                .font(.caption)
                .foregroundStyle(Color(uiColor: .secondaryLabel))

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
            Button(action: {
                showProfileEditor = true
            }, label: {
                instituteLogoView
                    .frame(width: 45, height: 45)
                    .background(Color(uiColor: .secondarySystemBackground), in: .circle)
                    .clipShape(.circle)
            })
        })
        .padding(15)
        .background(Color(uiColor: .systemBackground))
        .onChange(of: currentWeekIndex, initial: false) { _, newValue in
            if suppressWeekIndexObserver {
                return
            }

            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
        }
    }

    @ViewBuilder
    private var instituteLogoView: some View {
        if let logoName = StudyCatalog.logoAssetName(for: selectedFaculty), UIImage(named: logoName) != nil {
            Image(logoName)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(10)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }

    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E", locale: appLocale))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))

                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .textScale(.secondary)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : Color(uiColor: .secondaryLabel))
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                Circle()
                                    .fill(.mcuRed)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                            }

                            if day.date.isToday {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: 12)
                            }
                        })
                        .background(Color(uiColor: .secondarySystemBackground).shadow(.drop(radius: 1)), in: .circle)
                }
                .hSpacing(.center)
                .contentShape(.rect)
                .onTapGesture {
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
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    }
            }
        }
    }

    func paginateWeek() {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                weekSlider.insert(firstDate.createPreviousWeek(), at: 0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }

            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
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

    private var appLocale: Locale {
        Locale(identifier: appLanguage)
    }
}

#Preview {
    ContentView()
}
