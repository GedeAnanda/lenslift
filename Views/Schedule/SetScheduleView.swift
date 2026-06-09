//
//  SetScheduleView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct SetScheduleView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    @State var selectedDay: String
    @State private var selectedTemplateId = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Set Schedule")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.lensTextMuted)
                    }
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("DAY")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(.lensTextMuted)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.daysOfWeek, id: \.self) { day in
                                Button {
                                    selectedDay = day
                                } label: {
                                    Text(viewModel.daysOfWeekDisplay[day] ?? day)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(selectedDay == day ? .black : .white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedDay == day ? Color.lensGreen : Color.lensSurface)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("WORKOUT PROGRAM")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(.lensTextMuted)

                    if workoutViewModel.templates.isEmpty {
                        Text("No programs yet. Create one first.")
                            .font(.system(size: 14))
                            .foregroundColor(.lensTextMuted)
                    } else {
                        ForEach(workoutViewModel.templates, id: \.id) { template in
                            Button {
                                selectedTemplateId = template.id
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        Text(template.description)
                                            .font(.system(size: 13))
                                            .foregroundColor(.lensTextMuted)
                                    }
                                    Spacer()
                                    if selectedTemplateId == template.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.lensGreen)
                                    }
                                }
                                .padding(14)
                                .background(selectedTemplateId == template.id ? Color.lensSurface2 : Color.lensSurface)
                                .cornerRadius(12)
                            }
                        }
                    }
                }

                Spacer()

                Button {
                    guard !selectedDay.isEmpty && !selectedTemplateId.isEmpty else { return }
                    Task {
                        await viewModel.setSchedule(
                            dayOfWeek: selectedDay,
                            templateId: selectedTemplateId
                        )
                        dismiss()
                    }
                } label: {
                    Text("Save Schedule")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .background(Color.lensGreen)
                .cornerRadius(16)
                .padding(.bottom, 32)
                .disabled(selectedDay.isEmpty || selectedTemplateId.isEmpty)
            }
            .padding(.horizontal, 24)
        }
    }
}
