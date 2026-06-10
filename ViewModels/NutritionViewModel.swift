import Foundation
import SwiftUI
import Combine

class NutritionViewModel: ObservableObject {
    @Published var dailyLogs: DailyFoodLogs?
    @Published var isLoading = false
    @Published var isAnalyzing = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""

    private let foodService = FoodService.shared

    func loadDailyLogs(date: String? = nil) async {
        await setLoading(true)
        do {
            let result = try await foodService.getDailyLogs(date: date)
            await MainActor.run {
                dailyLogs = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal load data makanan")
            }
        }
    }

    func addFoodLog(
        foodName: String,
        calories: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double
    ) async {
        await setLoading(true)
        do {
            _ = try await foodService.addFoodLog(
                foodName: foodName,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG
            )
            await loadDailyLogs()
            await MainActor.run {
                successMessage = "\(foodName) berhasil ditambahkan"
                showSuccess = true
            }
        } catch APIError.serverError(let message) {
            await MainActor.run {
                isLoading = false
                showErrorMessage(message)
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal tambah makanan")
            }
        }
    }

    func deleteFoodLog(id: String) async {
        do {
            try await foodService.deleteFoodLog(id: id)
            await loadDailyLogs()
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal hapus log makanan")
            }
        }
    }

    var totalCalories: Double {
        dailyLogs?.dailySummary.totalCalories ?? 0
    }

    var targetCalories: Int {
        dailyLogs?.dailySummary.targetCalories ?? 0
    }

    var totalProtein: Double {
        dailyLogs?.dailySummary.totalProteinG ?? 0
    }

    var targetProtein: Int {
        dailyLogs?.dailySummary.targetProteinG ?? 0
    }

    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(totalCalories / Double(targetCalories), 1.0)
    }

    var proteinProgress: Double {
        guard targetProtein > 0 else { return 0 }
        return min(totalProtein / Double(targetProtein), 1.0)
    }

    var logs: [FoodLogResponse] {
        dailyLogs?.logs ?? []
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
