//
//  NutritionView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI
import PhotosUI

struct NutritionView: View {
    @StateObject var viewModel = NutritionViewModel()
    @State private var showAddFood = false
    @State private var showAnalyzer = false
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nutrition")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                                .font(.system(size: 13))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        // Calorie Ring Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color.lensSurface2, lineWidth: 8)
                                    .frame(width: 140, height: 140)

                                Circle()
                                    .trim(from: 0, to: viewModel.calorieProgress)
                                    .stroke(Color.lensGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 140, height: 140)
                                    .rotationEffect(.degrees(-90))

                                VStack(spacing: 2) {
                                    Text("\(Int(viewModel.totalCalories))")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("/ \(viewModel.targetCalories) kcal")
                                        .font(.system(size: 12))
                                        .foregroundColor(.lensTextMuted)
                                }
                            }

                            VStack(spacing: 8) {
                                MacroBar(label: "Protein", current: viewModel.totalProtein, target: Double(viewModel.targetProtein), color: .lensGreen)
                                MacroBar(label: "Carbs", current: viewModel.dailyLogs?.dailySummary.totalCarbsG ?? 0, target: 200, color: .lensText)
                                MacroBar(label: "Fat", current: viewModel.dailyLogs?.dailySummary.totalFatG ?? 0, target: 80, color: .lensText)
                            }
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)

                        // Add Food Button
                        HStack(spacing: 12) {
                            Button {
                                showAnalyzer = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                    Text("Scan Food")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.lensGreen)
                                .cornerRadius(12)
                            }

                            Button {
                                showAddFood = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("Manual")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.lensSurface)
                                .cornerRadius(12)
                            }
                        }

                        // Today's Log
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("TODAY'S LOG")
                                    .font(.system(size: 11, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(.lensTextMuted)
                                Spacer()
                                Text("\(viewModel.logs.count) items")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                            }

                            if viewModel.logs.isEmpty {
                                Text("No food logged yet")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lensTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(viewModel.logs, id: \.id) { log in
                                    FoodLogRow(log: log) {
                                        Task { await viewModel.deleteFoodLog(id: log.id) }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                if viewModel.isAnalyzing {
                    ZStack {
                        Color.black.opacity(0.8).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.lensGreen)
                                .scaleEffect(1.5)
                            Text("Analyzing your food...")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                Task { await viewModel.loadDailyLogs() }
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAnalyzer) {
                FoodAnalyzerView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") { viewModel.showSuccess = false }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
}

// MARK: - MacroBar
struct MacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.lensTextMuted)
                .frame(width: 50, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: 4)
                        .foregroundColor(.lensSurface2)
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: geo.size.width * progress, height: 4)
                        .foregroundColor(color)
                }
            }
            .frame(height: 4)

            Text("\(Int(current))g")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 45, alignment: .trailing)
        }
    }
}

// MARK: - FoodLogRow
struct FoodLogRow: View {
    let log: FoodLogResponse
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(log.foodName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    if log.source == "ai_photo" {
                        Text("AI")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.lensGreen)
                            .cornerRadius(4)
                    } else {
                        Text("Manual")
                            .font(.system(size: 10))
                            .foregroundColor(.lensTextMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.lensSurface2)
                            .cornerRadius(4)
                    }
                }
                Text("\(Int(log.proteinG))g protein")
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
            }

            Spacer()

            Text("\(Int(log.calories)) kcal")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.lensText)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.lensTextMuted)
            }
            .padding(.leading, 8)
        }
        .padding(14)
        .background(Color.lensSurface)
        .cornerRadius(12)
    }
}
