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
    @State private var currentTemplate: WorkoutTemplateResponse?
    @State private var currentExerciseIndex = 0
    @State private var actualReps = ""
    @State private var actualWeight = ""
    @State private var showEndConfirm = false
    @State private var showSummary = false
    @State private var sessionDetail: SessionDetailResponse?

    var currentExercise: ExerciseResponse? {
        currentTemplate?.exercises[safe: currentExerciseIndex]
    }

    var logsForCurrentExercise: [SessionLogResponse] {
        guard let exercise = currentExercise else { return [] }
        return viewModel.sessionLogs.filter { $0.exerciseName == exercise.exerciseName }
    }

    var nextSetNumber: Int {
        logsForCurrentExercise.count + 1
    }

    var isCurrentExerciseDone: Bool {
        guard let exercise = currentExercise else { return false }
        return logsForCurrentExercise.count >= exercise.targetSets
    }

    var isLastExercise: Bool {
        guard let template = currentTemplate else { return false }
        return currentExerciseIndex >= template.exercises.count - 1
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showSummary, let detail = sessionDetail {
                SessionSummaryView(detail: detail) {
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {

                    // Top Bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.lensTextMuted)
                                .font(.system(size: 20))
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(currentTemplate?.name ?? "Workout")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            Text(viewModel.formattedTime)
                                .font(.system(size: 13))
                                .foregroundColor(.lensGreen)
                                .monospacedDigit()
                        }
                        Spacer()
                        Button {
                            showEndConfirm = true
                        } label: {
                            Text("End")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // Exercise Progress Bar
                    if let template = currentTemplate {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Exercise \(currentExerciseIndex + 1) of \(template.exercises.count)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                                Spacer()
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(height: 4)
                                        .foregroundColor(.lensSurface2)
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: geo.size.width * CGFloat(currentExerciseIndex + 1) / CGFloat(template.exercises.count), height: 4)
                                        .foregroundColor(.lensGreen)
                                }
                            }
                            .frame(height: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }

                    ScrollView {
                        VStack(spacing: 20) {

                            if let exercise = currentExercise {

                                // Exercise Header
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(exercise.exerciseName)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Target: \(exercise.targetSets) sets × \(exercise.targetReps) reps")
                                        .font(.system(size: 14))
                                        .foregroundColor(.lensTextMuted)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                // Sets Progress
                                VStack(spacing: 8) {
                                    ForEach(1...exercise.targetSets, id: \.self) { setNum in
                                        let loggedSet = logsForCurrentExercise.first { $0.setNumber == setNum }
                                        HStack {
                                            // Set number indicator
                                            ZStack {
                                                Circle()
                                                    .frame(width: 32, height: 32)
                                                    .foregroundColor(loggedSet != nil ? Color.lensGreen : Color.lensSurface)
                                                if loggedSet != nil {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.black)
                                                } else {
                                                    Text("\(setNum)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(setNum == nextSetNumber ? .white : .lensTextMuted)
                                                }
                                            }

                                            Text("Set \(setNum)")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(loggedSet != nil ? .white : setNum == nextSetNumber ? .white : .lensTextMuted)

                                            Spacer()

                                            if let log = loggedSet {
                                                Text("\(Int(log.actualWeightKg))kg × \(log.actualReps)")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.lensGreen)
                                            } else if setNum == nextSetNumber {
                                                Text("Current")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.lensGreen)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color.lensGreen.opacity(0.15))
                                                    .cornerRadius(6)
                                            } else {
                                                Text("—")
                                                    .foregroundColor(.lensTextMuted)
                                            }
                                        }
                                        .padding(12)
                                        .background(setNum == nextSetNumber && loggedSet == nil ? Color.lensSurface2 : Color.lensSurface)
                                        .cornerRadius(12)
                                    }
                                }

                                // Log Form — hanya tampil kalau belum selesai
                                if !isCurrentExerciseDone {
                                    VStack(spacing: 12) {
                                        Text("LOG SET \(nextSetNumber)")
                                            .font(.system(size: 11, weight: .semibold))
                                            .tracking(2)
                                            .foregroundColor(.lensTextMuted)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("WEIGHT (kg)")
                                                    .font(.system(size: 10))
                                                    .tracking(1)
                                                    .foregroundColor(.lensTextMuted)
                                                TextField("0", text: $actualWeight)
                                                    .keyboardType(.decimalPad)
                                                    .font(.system(size: 28, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding()
                                                    .background(Color.lensSurface)
                                                    .cornerRadius(12)
                                            }

                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("REPS")
                                                    .font(.system(size: 10))
                                                    .tracking(1)
                                                    .foregroundColor(.lensTextMuted)
                                                TextField("\(exercise.targetReps)", text: $actualReps)
                                                    .keyboardType(.numberPad)
                                                    .font(.system(size: 28, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .padding()
                                                    .background(Color.lensSurface)
                                                    .cornerRadius(12)
                                            }
                                        }

                                        Button {
                                            guard let reps = Int(actualReps), reps > 0,
                                                  let weight = Double(actualWeight), weight > 0 else { return }
                                            Task {
                                                await viewModel.logSet(
                                                    exerciseName: exercise.exerciseName,
                                                    setNumber: nextSetNumber,
                                                    actualReps: reps,
                                                    actualWeightKg: weight
                                                )
                                                actualReps = "\(exercise.targetReps)"
                                                actualWeight = ""
                                            }
                                        } label: {
                                            Text("Log Set \(nextSetNumber)")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundColor(actualReps.isEmpty || actualWeight.isEmpty ? .lensTextMuted : .black)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 52)
                                        }
                                        .background(actualReps.isEmpty || actualWeight.isEmpty ? Color.lensSurface : Color.lensGreen)
                                        .cornerRadius(14)
                                        .disabled(actualReps.isEmpty || actualWeight.isEmpty)
                                    }
                                    .padding(16)
                                    .background(Color.lensSurface)
                                    .cornerRadius(16)
                                }

                                // Next Exercise / Finish Button
                                if isCurrentExerciseDone {
                                    if isLastExercise {
                                        Button {
                                            Task {
                                                sessionDetail = await viewModel.endSession()
                                                showSummary = true
                                            }
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "flag.checkered")
                                                Text("Finish Workout!")
                                            }
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                        }
                                        .background(Color.lensGreen)
                                        .cornerRadius(16)
                                    } else {
                                        Button {
                                            currentExerciseIndex += 1
                                            actualReps = "\(currentTemplate?.exercises[safe: currentExerciseIndex]?.targetReps ?? 0)"
                                            actualWeight = ""
                                        } label: {
                                            HStack(spacing: 8) {
                                                Text("Next Exercise")
                                                Image(systemName: "arrow.right")
                                            }
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 56)
                                        }
                                        .background(Color.lensGreen)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            if let templateId = viewModel.activeSession?.templateId {
                Task {
                    currentTemplate = try? await WorkoutService.shared.getTemplate(id: templateId)
                    if let first = currentTemplate?.exercises.first {
                        actualReps = "\(first.targetReps)"
                    }
                }
            }
        }
        .confirmationDialog("End Workout?", isPresented: $showEndConfirm) {
            Button("End Workout", role: .destructive) {
                Task {
                    sessionDetail = await viewModel.endSession()
                    showSummary = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end this workout?")
        }
    }
}

// MARK: - Session Summary
struct SessionSummaryView: View {
    let detail: SessionDetailResponse
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "flag.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(.lensGreen)

                Text("Workout Done!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                // Stats
                HStack(spacing: 0) {
                    SummaryStat(value: "\(detail.durationMinutes ?? 0)", unit: "min", label: "Duration")
                    Divider().background(Color.lensSurface2).frame(height: 40)
                    SummaryStat(value: "\(detail.totalSets)", unit: "sets", label: "Total Sets")
                    Divider().background(Color.lensSurface2).frame(height: 40)
                    SummaryStat(value: "\(Int(detail.totalVolumeKg))", unit: "kg", label: "Volume")
                }
                .padding(20)
                .background(Color.lensSurface)
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // Exercise breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("EXERCISE BREAKDOWN")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(.lensTextMuted)

                    let grouped = Dictionary(grouping: detail.logs, by: { $0.exerciseName })
                    ForEach(grouped.keys.sorted(), id: \.self) { exercise in
                        let sets = grouped[exercise] ?? []
                        HStack {
                            Text(exercise)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(sets.count) sets")
                                .font(.system(size: 13))
                                .foregroundColor(.lensGreen)
                        }
                        .padding(12)
                        .background(Color.lensSurface)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .background(Color.lensGreen)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - SummaryStat
struct SummaryStat: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
                    .padding(.bottom, 2)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.lensTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Safe Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
