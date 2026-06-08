//
//  HomeViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var profile: ProfileResponse?
    @Published var dailyFoodLogs: DailyFoodLogs?
    @Published var todaySchedule: ScheduleResponse?
    @Published var latestWeight: BodyWeightResponse?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    
    private let profileService = ProfileService.shared
    private let foodService = FoodService.shared
    private let scheduleService = ScheduleService.shared
    private let bodyWeightService = BodyWeightService.shared
    
    //MARK: - Load Dashboard
    func loadDashboard() {
        await setLoading(true)
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadProfile() }
            group.addTask { await self.loadTodayFood() }
            group.addTask { await self.loadTodaySchedule() }
            group.addTask { await self.loadLatestWeight() }
        }
        
        await setLoading(false)
    }
    
    // MARK: - Load Profile
    private func loadProfile() async {
        do {
            let result = try await profileService.getProfile()
            await MainActor.run {profile = result}
        } catch {
            print("Error load profile: \(error)")
        }
    }
    
    // MARK: - Load Today Schedule
    private func loadTodaySchedule() async {
        do {
            let schedules = try await scheduleService.getSchedules()
            let today = getTodayDayOfWeek()
            let result = schedules.first{$0.dayOfWeek == today}
            await MainActor.run {todaySchedule = result}
        }catch {
            print("Error load schedule: \(error)")
        }
    }
    
    // MARK: - Load Latest Weight
    private func loadLatestWeight() async {
        do {
            let result = try await bodyWeightService.getLatest()
            await MainActor.run { latestWeight = result }
        } catch {
            print("Error load weight: \(error)")
        }
    }
    
    // MARK: - Helpers
    @MainActor
    private func setLoading(_ value: Bool) {
        isLoading = value
    }
    
    private func getTodayDayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).lowercased()
    }

    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var totalCalories: Double {
        dailyFoodLogs?.dailySummary.totalCalories ?? 0
    }

    var targetCalories: Int {
        dailyFoodLogs?.dailySummary.targetCalories ?? 0
    }

    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(totalCalories / Double(targetCalories), 1.0)
    }
}
