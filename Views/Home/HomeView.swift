//
//  HomeView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.greetingMessage), \(viewModel.profile?.fullName ?? "there") 👋")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                                .font(.system(size: 13))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        // Calories Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CALORIES")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            HStack(alignment: .bottom, spacing: 6) {
                                Text("\(Int(viewModel.totalCalories))")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.white)
                                Text("/ \(viewModel.targetCalories) kcal")
                                    .font(.system(size: 15))
                                    .foregroundColor(.lensTextMuted)
                                    .padding(.bottom, 6)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(height: 4)
                                        .foregroundColor(.lensSurface2)
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: geo.size.width * viewModel.calorieProgress, height: 4)
                                        .foregroundColor(.lensGreen)
                                }
                            }
                            .frame(height: 4)

                            HStack(spacing: 8) {
                                MacroPill(label: "Protein", value: "\(Int(viewModel.dailyFoodLogs?.dailySummary.totalProteinG ?? 0))g")
                                MacroPill(label: "Carbs", value: "\(Int(viewModel.dailyFoodLogs?.dailySummary.totalCarbsG ?? 0))g")
                                MacroPill(label: "Fat", value: "\(Int(viewModel.dailyFoodLogs?.dailySummary.totalFatG ?? 0))g")
                            }
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)

                        // Today's Workout Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY'S WORKOUT")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            if let schedule = viewModel.todaySchedule {
                                Text(schedule.template.name)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)

                                Text("\(schedule.template.description)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.lensText)

                                Button {
                                } label: {
                                    Text("Start Workout")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                }
                                .background(Color.lensGreen)
                                .cornerRadius(12)
                            } else {
                                Text("Rest Day")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.lensTextMuted)
                                Text("No workout scheduled today")
                                    .font(.system(size: 13))
                                    .foregroundColor(.lensTextMuted)
                            }
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)

                        // Body Weight Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CURRENT WEIGHT")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            HStack(alignment: .bottom, spacing: 4) {
                                Text(String(format: "%.1f", viewModel.latestWeight?.weightKg ?? 0))
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("kg")
                                    .font(.system(size: 16))
                                    .foregroundColor(.lensTextMuted)
                                    .padding(.bottom, 4)
                            }

                            Text("Last updated today")
                                .font(.system(size: 12))
                                .foregroundColor(.lensTextMuted)
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                Task { await viewModel.loadDashboard() }
            }
        }
    }
}

// MARK: - MacroPill
struct MacroPill: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.lensTextMuted)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.lensSurface2)
        .cornerRadius(99)
    }
}
