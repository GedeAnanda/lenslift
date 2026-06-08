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
    
    private let api = APIAPIService.shared
    
    // MARK: - Templates
    func getTemplates() async throws -> [WorkoutTemplateListResponse] {
        return try await api.get(endpoint:"/workout-templates")
    }
    
    func getTemplate(id: String) async throws -> WorkoutTemplateResponse {
        return try await api.get(endpoint: "/workout-templates/\(id)")
    }
    
    func createTemplate(name:String, description: String, exercises: [ExerciseRequest]) async throws ->  WorkoutTemplateResponse{
        let body = WorkoutTemplateRequest(name: name, description: description, exercises: exercises)
        
        return try await api.post(endpoint: "/workout-templates", body:body)
    }
    
    func updateTemplate(id: String, name: String, description: String, exercises: [ExerciseRequest]) async throws -> WorkoutTemplateResponse {
        let body = WorkoutTemplateRequest(name: name, description: description, exercises: exercises)
        return try await api.put(endpoint: "/workout-templates\(id)", body:body)
    }
    
    func deleteTemplate(id: String) async throws {
        try await api.delete(endpoint: "/workout-templates/\(id)")
    }
    
    //MARK: - Sessions
    func startSession(templateId: String? = nil) async throws -> SessionResponse {
        let body = StartSessionRequest(templateId: templateId)
        return try await api.post(endpoint: "/sessions/start", body: body)
    }
    
    func logSet(sessionId: String, exerciseName:String, setNumber:Int, actualReps: Int, actualWeight: Int) async throws -> SessionLogResponse {
        let body = LogSetRequest(
            exerciseName: exerciseName,
            setNumber: setNumber,
            actualReps: actualReps,
            actualWeight: actualWeight
        )
        
        return try await api.post(endpoint:".sessions/\(sessionId)/log", body: body)
    }
    
    func endSession(sessionId: String) async throws -> SessionDetailResponse {
        let body = EndSessionRequest()
        return try await api.post(endpoint: "/sessions/\(sessionId).end", body: body)
    }
    
    func getSessions() async throws -> [SessionResponse] {
        return try await api.get(endpoint: "/sessions")
    }
    
    func getSession(id: String) async throws -> SessionDetailResponse {
        return try await api.get(endpoint: "/sessions/\(id)")
    }
    
    
}
