//
//  WorkoutModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//


import Foundation

// MARK: - Template Request
struct ExerciseRequest: Codable {
    let exerciseName: String
    let targetSets: Int
    let targetReps: Int
    let notes: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case targetSets = "target_sets"
        case targetReps = "target_reps"
        case notes
        case orderIndex = "order_index"
    }
}

struct WorkoutTemplateRequest: Codable {
    let name: String
    let description: String
    let exercises: [ExerciseRequest]
}

// MARK: - Template Response
struct ExerciseResponse: Codable {
    let id: String
    let exerciseName: String
    let targetSets: Int
    let targetReps: Int
    let notes: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseName = "exercise_name"
        case targetSets = "target_sets"
        case targetReps = "target_reps"
        case notes
        case orderIndex = "order_index"
    }
}

struct WorkoutTemplateResponse: Codable {
    let id: String
    let name: String
    let description: String
    let exercises: [ExerciseResponse]
}

struct WorkoutTemplateListResponse: Codable {
    let id: String
    let name: String
    let description: String
}

// MARK: - Session Request
struct StartSessionRequest: Codable {
    let templateId: String?
    
    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
    }
}

struct LogSetRequest: Codable {
    let exerciseName: String
    let setNumber: Int
    let actualReps: Int
    let actualWeightKg: Double
    
    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case setNumber = "set_number"
        case actualReps = "actual_reps"
        case actualWeightKg = "actual_weight_kg"
    }
}

// MARK: - Session Response
struct SessionResponse: Codable {
    let id: String
    let templateId: String?
    let startedAt: String
    let endedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
    }
}

struct SessionLogResponse: Codable {
    let id: String
    let exerciseName: String
    let setNumber: Int
    let actualReps: Int
    let actualWeightKg: Double
    let loggedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseName = "exercise_name"
        case setNumber = "set_number"
        case actualReps = "actual_reps"
        case actualWeightKg = "actual_weight_kg"
        case loggedAt = "logged_at"
    }
}

struct SessionDetailResponse: Codable {
    let id: String
    let templateId: String?
    let startedAt: String
    let endedAt: String?
    let durationMinutes: Int?
    let totalSets: Int
    let totalVolumeKg: Double
    let logs: [SessionLogResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationMinutes = "duration_minutes"
        case totalSets = "total_sets"
        case totalVolumeKg = "total_volume_kg"
        case logs
    }
}
