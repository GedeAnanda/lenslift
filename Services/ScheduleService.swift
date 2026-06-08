//
//  ScheduleService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class ScheduleService {
    static let shared = ScheduleService()
    
    private init() {}
    
    private let api = APIService.shared
    
    // MARK: - Get All Schedules
    func getSchedules() async throws -> [ScheduleResponse] {
        return try await api.get(endpoint:"/schedules")
    }
    
    // MARK: - Set Schedule
    func setSchedule(dayOfWeek: String, templateId: String) async throws -> ScheduleResponse {
        let body = ScheduleRequest(dayOfWeek: dayOfWeek, templateId: templateId)
        return try await api.post(endpoint: "/schedules", body: body)
    }
    
    // MARK: - Delete Schedule
    func deleteSchedule(day: String) async throws {
        try await api.delete(endpoint: "/schedules/\(day)")
    }
}
