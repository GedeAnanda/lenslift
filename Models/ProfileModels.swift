//
//  ProfileModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//


import Foundation

//MARK: -Request
struct UpdateProfileRequest: Codable {
    let fullName: String
    let weightKg: Double
    let heightCm: Double
    let age: Int
    let gender: String
    let goal: String
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case age
        case gender
        case goal
    }
}

// MARK: - Response
struct ProfileResponse: Codable {
    let id: String
    let fullName: String
    let weightKg: Double
    let heightCm: Double
    let age: Int
    let gender: String
    let goal: String
    let targetCalories: Int
    let targetProteinG: Int

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case age
        case gender
        case goal
        case targetCalories = "target_calories"
        case targetProteinG = "target_protein_g"
    }
}
