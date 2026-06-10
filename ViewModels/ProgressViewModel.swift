//
//  ProgressViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import Combine

class ProgressViewModel: ObservableObject {
    @Published var weightHistory: [BodyWeightResponse] = []
    @Published var recentSessions: [SessionResponse] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false

    private let bodyWeightService = BodyWeightService.shared
    private let workoutService = WorkoutService.shared

    func loadProgress() async {
        await setLoading(true)
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWeightHistory() }
            group.addTask { await self.loadRecentSessions() }
        }
        await setLoading(false)
    }

    private func loadWeightHistory() async {
        do {
            let result = try await bodyWeightService.getHistory()
            await MainActor.run { weightHistory = result }
        } catch {
            print("Error load weight history: \(error)")
        }
    }

    private func loadRecentSessions() async {
        do {
            let result = try await workoutService.getSessions()
            await MainActor.run {
                recentSessions = Array(result.prefix(10))
            }
        } catch {
            print("Error load sessions: \(error)")
        }
    }

    func logWeight(weightKg: Double, notes: String = "") async {
        do {
            _ = try await bodyWeightService.logWeight(weightKg: weightKg, notes: notes)
            await loadWeightHistory()
        } catch APIError.serverError(let message) {
            await MainActor.run { showErrorMessage(message) }
        } catch {
            await MainActor.run { showErrorMessage("Gagal log berat badan") }
        }
    }

    func deleteWeight(id: String) async {
        do {
            try await bodyWeightService.deleteWeight(id: id)
            await loadWeightHistory()
        } catch {
            await MainActor.run { showErrorMessage("Gagal hapus data") }
        }
    }

    var latestWeight: Double {
        weightHistory.first?.weightKg ?? 0
    }

    var weightChange: Double {
        guard weightHistory.count >= 2 else { return 0 }
        return weightHistory[0].weightKg - weightHistory[weightHistory.count - 1].weightKg
    }

    var weeklyWorkouts: Int {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        return recentSessions.filter { session in
            guard let date = ISO8601DateFormatter().date(from: session.startedAt) else { return false }
            return date >= weekAgo
        }.count
    }

    var completedSessions: Int {
        recentSessions.filter { $0.endedAt != nil }.count
    }

    @MainActor
    private func setLoading(_ value: Bool) {
        isLoading = value
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
