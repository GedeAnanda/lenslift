//
//  WorkoutView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject var viewModel = WorkoutViewModel()
    @State private var showCreateTemplate = false
    @State private var activeSession: SessionResponse?
    @State private var showActiveSession = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Workout")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("Your programs")
                                .font(.system(size: 13))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        // Active Session Banner
                        if viewModel.isSessionActive {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Session Active")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text(viewModel.formattedTime)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                Button {
                                    showActiveSession = true
                                } label: {
                                    Text("Resume")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.lensGreen)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(16)
                            .background(Color.lensGreen)
                            .cornerRadius(16)
                        }

                        // Templates
                        if viewModel.templates.isEmpty && !viewModel.isLoading {
                            VStack(spacing: 12) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 40))
                                    .foregroundColor(.lensTextMuted)
                                Text("No programs yet")
                                    .font(.system(size: 16))
                                    .foregroundColor(.lensTextMuted)
                                Text("Create your first workout program")
                                    .font(.system(size: 13))
                                    .foregroundColor(.lensTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else {
                            ForEach(viewModel.templates, id: \.id) { template in
                                NavigationLink(destination: TemplateDetailView(templateId: template.id, workoutViewModel: viewModel)) {
                                    TemplateCard(template: template) {
                                        Task {
                                            await viewModel.startSession(templateId: template.id)
                                            showActiveSession = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                // FAB Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showCreateTemplate = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 56, height: 56)
                                .background(Color.lensGreen)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .onAppear {
                Task { await viewModel.loadTemplates() }
            }
            .sheet(isPresented: $showCreateTemplate) {
                CreateTemplateView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showActiveSession) {
                ActiveSessionView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - TemplateCard
struct TemplateCard: View {
    let template: WorkoutTemplateListResponse
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(template.description)
                        .font(.system(size: 13))
                        .foregroundColor(.lensText)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.lensTextMuted)
                    .font(.system(size: 14))
            }

            Button {
                onStart()
            } label: {
                Text("Start Workout")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .background(Color.lensGreen)
            .cornerRadius(10)
        }
        .padding(16)
        .background(Color.lensSurface)
        .cornerRadius(16)
    }
}
