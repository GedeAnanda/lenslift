//
//  TemplateDetailView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct TemplateDetailView: View {
    let templateId: String
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var template: WorkoutTemplateResponse?
    @State private var showEdit = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let template = template {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(template.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text(template.description)
                                .font(.system(size: 14))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("EXERCISES")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            ForEach(template.exercises, id: \.id) { exercise in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.exerciseName)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        Text("\(exercise.targetSets) sets × \(exercise.targetReps) reps")
                                            .font(.system(size: 13))
                                            .foregroundColor(.lensTextMuted)
                                    }
                                    Spacer()
                                    Text("#\(exercise.orderIndex)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.lensTextMuted)
                                }
                                .padding(14)
                                .background(Color.lensSurface)
                                .cornerRadius(12)
                            }
                        }

                        Button {
                            Task {
                                await workoutViewModel.deleteTemplate(id: templateId)
                                dismiss()
                            }
                        } label: {
                            Text("Delete Template")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.lensSurface)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                template = try? await WorkoutService.shared.getTemplate(id: templateId)
            }
        }
    }
}
