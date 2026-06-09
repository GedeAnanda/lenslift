//
//  ProgressViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import SwiftUI
import Combine

class ProgressViewModel: ObservableObject {
    @Published var weightHistory: [BodyWeightResponse] = []
    @Published var recentSessions: [SessionResponse] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false

    private let bodyWeightService = BodyWeightService.shared
    private let workoutService = WorkoutService.shared

    // MARK: - Load Progress
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
            await MainActor.run { recentSessions = result }
        } catch {
            print("Error load sessions: \(error)")
        }
    }

    // MARK: - Log Weight
    func logWeight(weightKg: Double, notes: String) async {
        do {
            _ = try await bodyWeightService.logWeight(weightKg: weightKg, notes: notes)
            await loadWeightHistory()
        } catch APIError.serverError(let message) {
            await MainActor.run { showErrorMessage(message) }
        } catch {
            await MainActor.run { showErrorMessage("Gagal log berat badan") }
        }
    }

    // MARK: - Delete Weight
    func deleteWeight(id: String) async {
        do {
            try await bodyWeightService.deleteWeight(id: id)
            await loadWeightHistory()
        } catch {
            await MainActor.run { showErrorMessage("Gagal hapus data berat") }
        }
    }

    // MARK: - Computed
    var latestWeight: Double {
        weightHistory.first?.weightKg ?? 0
    }

    var weightChange: Double {
        guard let latest = weightHistory.first?.weightKg,
              let oldest = weightHistory.last?.weightKg,
              weightHistory.count > 1 else { return 0 }
        return latest - oldest
    }

    var weeklyWorkouts: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return 0 }
        let formatter = ISO8601DateFormatter()
        return recentSessions.filter { session in
            guard let date = formatter.date(from: session.startedAt) else { return false }
            return date >= weekAgo
        }.count
    }

    // MARK: - Helpers
    @MainActor
    private func setLoading(_ value: Bool) {
        isLoading = value
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
