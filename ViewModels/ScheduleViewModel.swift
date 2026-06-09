//
//  ScheduleViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import Combine

class ScheduleViewModel: ObservableObject {
    @Published var schedules: [ScheduleResponse] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false

    private let scheduleService = ScheduleService.shared

    // MARK: - Load Schedules
    func loadSchedules() async {
        await setLoading(true)
        do {
            let result = try await scheduleService.getSchedules()
            await MainActor.run {
                schedules = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal load jadwal")
            }
        }
    }

    // MARK: - Set Schedule
    func setSchedule(dayOfWeek: String, templateId: String) async {
        do {
            _ = try await scheduleService.setSchedule(
                dayOfWeek: dayOfWeek,
                templateId: templateId
            )
            await loadSchedules()
        } catch APIError.serverError(let message) {
            await MainActor.run {
                showErrorMessage(message)
            }
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal set jadwal")
            }
        }
    }

    // MARK: - Delete Schedule
    func deleteSchedule(day: String) async {
        do {
            try await scheduleService.deleteSchedule(day: day)
            await loadSchedules()
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal hapus jadwal")
            }
        }
    }

    // MARK: - Helpers
    var daysOfWeek: [String] {
        ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    }

    var daysOfWeekDisplay: [String: String] {
        [
            "monday": "Monday",
            "tuesday": "Tuesday",
            "wednesday": "Wednesday",
            "thursday": "Thursday",
            "friday": "Friday",
            "saturday": "Saturday",
            "sunday": "Sunday"
        ]
    }

    func scheduleForDay(_ day: String) -> ScheduleResponse? {
        schedules.first { $0.dayOfWeek == day }
    }

    func isToday(_ day: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date()).lowercased() == day
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
