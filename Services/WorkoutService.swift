//
//  WorkoutService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class WorkoutService {
    static let shared = WorkoutService()
    private init() {}
    
    private let api = APIService.shared
    
    // MARK: - Templates
    func getTemplates() async throws -> [WorkoutTemplateListResponse] {
        return try await api.get(endpoint:"/api/workout-templates")
    }
    
    func getTemplate(id: String) async throws -> WorkoutTemplateResponse {
        return try await api.get(endpoint: "/api/workout-templates/\(id)")
    }
    
    func createTemplate(name: String, description: String, exercises: [ExerciseRequest]) async throws -> WorkoutTemplateResponse {
        let body = WorkoutTemplateRequest(name: name, description: description, exercises: exercises)
        return try await api.post(endpoint: "/api/workout-templates", body: body)
    }
    
    func updateTemplate(id: String, name: String, description: String, exercises: [ExerciseRequest]) async throws -> WorkoutTemplateResponse {
        let body = WorkoutTemplateRequest(name: name, description: description, exercises: exercises)
        return try await api.put(endpoint: "/api/workout-templates/\(id)", body: body)
    }
    
    func deleteTemplate(id: String) async throws {
        try await api.delete(endpoint: "/api/workout-templates/\(id)")
    }
    
    //MARK: - Sessions
    func startSession(templateId: String? = nil) async throws -> SessionResponse {
        let body = StartSessionRequest(templateId: templateId)
        return try await api.post(endpoint: "/api/sessions/start", body: body)
    }
    
    func logSet(sessionId: String, exerciseName: String, setNumber: Int, actualReps: Int, actualWeightKg: Double) async throws -> SessionLogResponse {
        let body = LogSetRequest(
            exerciseName: exerciseName,
            setNumber: setNumber,
            actualReps: actualReps,
            actualWeightKg: actualWeightKg
        )
        
        return try await api.post(endpoint: "/api/sessions/\(sessionId)/log", body: body)
    }
    
    func endSession(sessionId: String) async throws -> SessionDetailResponse {
        let body = EndSessionRequest()
        return try await api.post(endpoint: "/api/sessions/\(sessionId)/end", body: body)
    }
    
    func getSessions() async throws -> [SessionResponse] {
        return try await api.get(endpoint: "/api/sessions")
    }
    
    func getSession(id: String) async throws -> SessionDetailResponse {
        return try await api.get(endpoint: "/api/sessions/\(id)")
    }
}
