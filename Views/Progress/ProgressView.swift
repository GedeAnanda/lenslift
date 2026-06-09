//
//  ProgressView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct ProgressTrackingView: View {
    @StateObject var viewModel = ProgressViewModel()
    @State private var showLogWeight = false
    @State private var weightInput = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("Your journey")
                                .font(.system(size: 13))
                                .foregroundColor(.lensText)
                        }
                        .padding(.top, 8)

                        // Body Weight Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BODY WEIGHT")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            HStack(alignment: .bottom, spacing: 8) {
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text(String(format: "%.1f", viewModel.latestWeight))
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("kg")
                                        .font(.system(size: 16))
                                        .foregroundColor(.lensTextMuted)
                                        .padding(.bottom, 4)
                                }

                                Spacer()

                                if viewModel.weightChange != 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: viewModel.weightChange > 0 ? "arrow.up" : "arrow.down")
                                            .font(.system(size: 12))
                                        Text(String(format: "%.1f kg this month", abs(viewModel.weightChange)))
                                            .font(.system(size: 13))
                                    }
                                    .foregroundColor(viewModel.weightChange < 0 ? .lensGreen : .lensText)
                                }
                            }

                            // Simple Weight Chart
                            if viewModel.weightHistory.count > 1 {
                                WeightChart(weights: viewModel.weightHistory)
                                    .frame(height: 80)
                            }

                            Button {
                                showLogWeight = true
                            } label: {
                                Text("Log Weight")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                            .background(Color.lensGreen)
                            .cornerRadius(12)
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)

                        // This Week Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("THIS WEEK")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            HStack(spacing: 0) {
                                WeekStat(value: "\(viewModel.weeklyWorkouts)", label: "Workouts")
                                Divider()
                                    .background(Color.lensSurface2)
                                    .frame(height: 40)
                                WeekStat(value: "\(viewModel.recentSessions.count)", label: "Sessions")
                                Divider()
                                    .background(Color.lensSurface2)
                                    .frame(height: 40)
                                WeekStat(value: "\(viewModel.weightHistory.count)", label: "Logs")
                            }
                        }
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(20)

                        // Recent Sessions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECENT SESSIONS")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            if viewModel.recentSessions.isEmpty {
                                Text("No sessions yet")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lensTextMuted)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(viewModel.recentSessions, id: \.id) { session in
                                    SessionRow(session: session)
                                }
                            }
                        }

                        // Weight History
                        if !viewModel.weightHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("WEIGHT HISTORY")
                                    .font(.system(size: 11, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(.lensTextMuted)

                                ForEach(viewModel.weightHistory.prefix(5), id: \.id) { weight in
                                    HStack {
                                        Text(weight.measuredDate)
                                            .font(.system(size: 13))
                                            .foregroundColor(.lensTextMuted)
                                        Spacer()
                                        Text(String(format: "%.1f kg", weight.weightKg))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                        Button {
                                            Task { await viewModel.deleteWeight(id: weight.id) }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundColor(.lensTextMuted)
                                        }
                                        .padding(.leading, 8)
                                    }
                                    .padding(14)
                                    .background(Color.lensSurface)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                Task { await viewModel.loadProgress() }
            }
            .sheet(isPresented: $showLogWeight) {
                LogWeightView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - WeightChart
struct WeightChart: View {
    let weights: [BodyWeightResponse]

    var body: some View {
        GeometryReader { geo in
            let values = weights.prefix(10).map { $0.weightKg }.reversed()
            let minVal = values.min() ?? 0
            let maxVal = values.max() ?? 1
            let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
            let points = Array(values).enumerated().map { index, val in
                CGPoint(
                    x: geo.size.width * CGFloat(index) / CGFloat(max(values.count - 1, 1)),
                    y: geo.size.height * (1 - CGFloat((val - minVal) / range))
                )
            }

            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.lensGreen, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            ForEach(points.indices, id: \.self) { i in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(.lensGreen)
                    .position(points[i])
            }
        }
    }
}

// MARK: - WeekStat
struct WeekStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.lensTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SessionRow
struct SessionRow: View {
    let session: SessionResponse

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.templateId != nil ? "Workout Session" : "Free Session")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                Text(session.startedAt)
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
            }
            Spacer()
            if session.endedAt != nil {
                Text("Done")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.lensGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.lensGreen.opacity(0.15))
                    .cornerRadius(6)
            }
        }
        .padding(14)
        .background(Color.lensSurface)
        .cornerRadius(12)
    }
}
