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
    @State private var selectedSession: SessionResponse?
    @State private var showSessionDetail = false

    var body: some View {
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

                        HStack(alignment: .bottom) {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text(String(format: "%.1f", viewModel.latestWeight))
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.white)
                                Text("kg")
                                    .font(.system(size: 16))
                                    .foregroundColor(.lensTextMuted)
                                    .padding(.bottom, 6)
                            }

                            Spacer()

                            if viewModel.weightChange != 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.weightChange < 0 ? "arrow.down" : "arrow.up")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(String(format: "%.1f kg", abs(viewModel.weightChange)))
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(viewModel.weightChange < 0 ? .lensGreen : .orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(viewModel.weightChange < 0 ? Color.lensGreen.opacity(0.15) : Color.orange.opacity(0.15))
                                .cornerRadius(20)
                            }
                        }

                        if viewModel.weightHistory.count > 1 {
                            WeightChart(weights: viewModel.weightHistory)
                                .frame(height: 80)
                        }

                        Button {
                            showLogWeight = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Log Weight")
                                    .font(.system(size: 15, weight: .semibold))
                            }
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
                            WeekStat(value: "\(viewModel.weeklyWorkouts)", label: "Workouts", icon: "dumbbell.fill")
                            Divider().background(Color.lensSurface2).frame(height: 40)
                            WeekStat(value: "\(viewModel.completedSessions)", label: "Completed", icon: "checkmark.circle.fill")
                            Divider().background(Color.lensSurface2).frame(height: 40)
                            WeekStat(value: "\(viewModel.weightHistory.count)", label: "Weigh-ins", icon: "scalemass.fill")
                        }
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)

                    // Recent Sessions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WORKOUT HISTORY")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        if viewModel.recentSessions.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 32))
                                    .foregroundColor(.lensTextMuted)
                                Text("No workouts yet")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lensTextMuted)
                                Text("Start your first session from the Workout tab")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else {
                            ForEach(viewModel.recentSessions, id: \.id) { session in
                                SessionHistoryCard(session: session)
                                    .onTapGesture {
                                        selectedSession = session
                                        showSessionDetail = true
                                    }
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

                            ForEach(viewModel.weightHistory.prefix(7), id: \.id) { weight in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatDate(weight.measuredDate))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        if !weight.notes.isEmpty {
                                            Text(weight.notes)
                                                .font(.system(size: 12))
                                                .foregroundColor(.lensTextMuted)
                                        }
                                    }
                                    Spacer()
                                    Text(String(format: "%.1f kg", weight.weightKg))
                                        .font(.system(size: 16, weight: .bold))
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
        .sheet(isPresented: $showSessionDetail) {
            if let session = selectedSession {
                SessionDetailSheet(sessionId: session.id)
            }
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateStr) {
            let display = DateFormatter()
            display.dateFormat = "EEE, d MMM yyyy"
            return display.string(from: date)
        }
        return dateStr
    }
}

// MARK: - SessionHistoryCard
struct SessionHistoryCard: View {
    let session: SessionResponse

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(session.endedAt != nil ? Color.lensGreen.opacity(0.15) : Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: session.endedAt != nil ? "checkmark" : "clock")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(session.endedAt != nil ? .lensGreen : .orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.templateId != nil ? "Gym Session" : "Free Session")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(formatSessionDate(session.startedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.lensTextMuted)

                    if let ended = session.endedAt {
                        Text("•")
                            .foregroundColor(.lensTextMuted)
                        Text(duration(start: session.startedAt, end: ended))
                            .font(.system(size: 12))
                            .foregroundColor(.lensTextMuted)
                    } else {
                        Text("• In progress")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.lensTextMuted)
        }
        .padding(14)
        .background(Color.lensSurface)
        .cornerRadius(14)
    }

    private func formatSessionDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateStr) {
            let display = DateFormatter()
            display.dateFormat = "EEE, d MMM"
            return display.string(from: date)
        }
        return dateStr
    }

    private func duration(start: String, end: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else { return "" }
        let minutes = Int(endDate.timeIntervalSince(startDate) / 60)
        return "\(minutes) min"
    }
}

// MARK: - SessionDetailSheet
struct SessionDetailSheet: View {
    let sessionId: String
    @State private var detail: SessionDetailResponse?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Session Detail")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.lensTextMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                if let detail = detail {
                    ScrollView {
                        VStack(spacing: 16) {

                            // Stats
                            HStack(spacing: 0) {
                                SummaryStat(value: "\(detail.durationMinutes ?? 0)", unit: "min", label: "Duration")
                                Divider().background(Color.lensSurface2).frame(height: 40)
                                SummaryStat(value: "\(detail.totalSets)", unit: "sets", label: "Total Sets")
                                Divider().background(Color.lensSurface2).frame(height: 40)
                                SummaryStat(value: "\(Int(detail.totalVolumeKg))", unit: "kg", label: "Volume")
                            }
                            .padding(16)
                            .background(Color.lensSurface)
                            .cornerRadius(16)

                            // Exercise Breakdown
                            if !detail.logs.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("EXERCISE LOG")
                                        .font(.system(size: 11, weight: .semibold))
                                        .tracking(2)
                                        .foregroundColor(.lensTextMuted)

                                    let grouped = Dictionary(grouping: detail.logs, by: { $0.exerciseName })
                                    ForEach(grouped.keys.sorted(), id: \.self) { exercise in
                                        let sets = (grouped[exercise] ?? []).sorted { $0.setNumber < $1.setNumber }
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(exercise)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)

                                            ForEach(sets, id: \.id) { log in
                                                HStack {
                                                    HStack(spacing: 6) {
                                                        ZStack {
                                                            Circle()
                                                                .fill(Color.lensGreen)
                                                                .frame(width: 24, height: 24)
                                                            Text("\(log.setNumber)")
                                                                .font(.system(size: 11, weight: .bold))
                                                                .foregroundColor(.black)
                                                        }
                                                        Text("Set \(log.setNumber)")
                                                            .font(.system(size: 13))
                                                            .foregroundColor(.lensTextMuted)
                                                    }
                                                    Spacer()
                                                    Text("\(Int(log.actualWeightKg)) kg × \(log.actualReps) reps")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .padding(14)
                                        .background(Color.lensSurface)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                } else {
                    Spacer()
                    ProgressView()
                        .tint(.lensGreen)
                    Spacer()
                }
            }
        }
        .onAppear {
            Task {
                detail = try? await WorkoutService.shared.getSession(id: sessionId)
            }
        }
    }
}

// MARK: - WeightChart
struct WeightChart: View {
    let weights: [BodyWeightResponse]

    var body: some View {
        GeometryReader { geo in
            let values = Array(weights.prefix(10).map { $0.weightKg }.reversed())
            let minVal = (values.min() ?? 0) - 1
            let maxVal = (values.max() ?? 1) + 1
            let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
            let points = values.enumerated().map { index, val in
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
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.lensGreen)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.lensTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

