//
//  ActiveSessionView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct ActiveSessionView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var exerciseName = ""
    @State private var setNumber = "1"
    @State private var actualReps = ""
    @State private var actualWeight = ""
    @State private var showEndConfirm = false
    @State private var sessionDetail: SessionDetailResponse?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.lensTextMuted)
                            .font(.system(size: 20))
                    }
                    Spacer()
                    Text("...")
                        .foregroundColor(.lensTextMuted)
                }
                .padding(.top, 16)

                Text("Push Day")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(viewModel.formattedTime)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.lensGreen)
                    .monospacedDigit()

                Text("Exercise \(viewModel.sessionLogs.count + 1)")
                    .font(.system(size: 14))
                    .foregroundColor(.lensTextMuted)

                VStack(spacing: 12) {
                    InputField(placeholder: "Exercise Name", text: $exerciseName)
                    HStack(spacing: 12) {
                        InputField(placeholder: "Set #", text: $setNumber, keyboardType: .numberPad)
                        InputField(placeholder: "Weight (kg)", text: $actualWeight, keyboardType: .decimalPad)
                        InputField(placeholder: "Reps", text: $actualReps, keyboardType: .numberPad)
                    }

                    Button {
                        Task {
                            await viewModel.logSet(
                                exerciseName: exerciseName,
                                setNumber: Int(setNumber) ?? 1,
                                actualReps: Int(actualReps) ?? 0,
                                actualWeightKg: Double(actualWeight) ?? 0
                            )
                            setNumber = String((Int(setNumber) ?? 1) + 1)
                            actualReps = ""
                        }
                    } label: {
                        Text("Log Set")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                    .background(Color.lensGreen)
                    .cornerRadius(12)
                }

                if !viewModel.sessionLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LOGGED SETS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        ForEach(viewModel.sessionLogs, id: \.id) { log in
                            HStack {
                                Text("Set \(log.setNumber)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.lensTextMuted)
                                Text(log.exerciseName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(log.actualWeightKg))kg × \(log.actualReps)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.lensGreen)
                            }
                            .padding(10)
                            .background(Color.lensSurface)
                            .cornerRadius(8)
                        }
                    }
                }

                Spacer()

                Button {
                    showEndConfirm = true
                } label: {
                    Text("End Workout")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.5), lineWidth: 0.5)
                        )
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .confirmationDialog("End Workout?", isPresented: $showEndConfirm) {
            Button("End Workout", role: .destructive) {
                Task {
                    sessionDetail = await viewModel.endSession()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end this workout?")
        }
    }
}
