//
//  ScheduleView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject var viewModel = ScheduleViewModel()
    @StateObject var workoutViewModel = WorkoutViewModel()
    @State private var showSetSchedule = false
    @State private var selectedDay = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Schedule")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("Your weekly plan")
                                .font(.system(size: 13))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        ForEach(viewModel.daysOfWeek, id: \.self) { day in
                            DayScheduleRow(
                                day: day,
                                displayName: viewModel.daysOfWeekDisplay[day] ?? day,
                                schedule: viewModel.scheduleForDay(day),
                                isToday: viewModel.isToday(day),
                                onSet: {
                                    selectedDay = day
                                    showSetSchedule = true
                                },
                                onDelete: {
                                    Task { await viewModel.deleteSchedule(day: day) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadSchedules()
                    await workoutViewModel.loadTemplates()
                }
            }
            .sheet(isPresented: $showSetSchedule) {
                SetScheduleView(
                    viewModel: viewModel,
                    workoutViewModel: workoutViewModel,
                    selectedDay: selectedDay
                )
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - DayScheduleRow
struct DayScheduleRow: View {
    let day: String
    let displayName: String
    let schedule: ScheduleResponse?
    let isToday: Bool
    let onSet: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isToday ? .lensGreen : .white)
                if isToday {
                    Text("TODAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.lensGreen)
                        .cornerRadius(4)
                }
                Spacer()
            }

            if let schedule = schedule {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(schedule.template.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text(schedule.template.description)
                            .font(.system(size: 13))
                            .foregroundColor(.lensTextMuted)
                    }
                    Spacer()
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.lensTextMuted)
                    }
                }
            } else {
                Button {
                    onSet()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                        Text("Set Program")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.lensGreen)
                }
            }
        }
        .padding(16)
        .background(Color.lensSurface)
        .cornerRadius(16)
    }
}
