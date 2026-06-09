//
//  CreateTemplateView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct CreateTemplateView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var exercises: [ExerciseInput] = [ExerciseInput()]

    struct ExerciseInput: Identifiable {
        let id = UUID()
        var name = ""
        var sets = ""
        var reps = ""
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("New Program")
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

                    VStack(spacing: 12) {
                        InputField(placeholder: "Program Name (e.g. Push Day)", text: $name)
                        InputField(placeholder: "Description (e.g. Chest, Shoulder, Tricep)", text: $description)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("EXERCISES")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        ForEach($exercises) { $exercise in
                            VStack(spacing: 8) {
                                InputField(placeholder: "Exercise Name", text: $exercise.name)
                                HStack(spacing: 8) {
                                    InputField(placeholder: "Sets", text: $exercise.sets, keyboardType: .numberPad)
                                    InputField(placeholder: "Reps", text: $exercise.reps, keyboardType: .numberPad)
                                }
                            }
                            .padding(12)
                            .background(Color.lensSurface)
                            .cornerRadius(12)
                        }

                        Button {
                            exercises.append(ExerciseInput())
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle")
                                Text("Add Exercise")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.lensGreen)
                        }
                    }

                    Button {
                        Task {
                            let exerciseRequests = exercises.enumerated().map { index, ex in
                                ExerciseRequest(
                                    exerciseName: ex.name,
                                    targetSets: Int(ex.sets) ?? 3,
                                    targetReps: Int(ex.reps) ?? 10,
                                    notes: "",
                                    orderIndex: index + 1
                                )
                            }
                            await viewModel.createTemplate(
                                name: name,
                                description: description,
                                exercises: exerciseRequests
                            )
                            dismiss()
                        }
                    } label: {
                        Text("Create Program")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .background(Color.lensGreen)
                    .cornerRadius(16)
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
