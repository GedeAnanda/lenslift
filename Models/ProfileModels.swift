//
//  ProfileModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//


import Foundation

//MARK: -Request
struct UpdateProfileRequest: Codable {
    let fullname: String
    let weightKg: Double
    let heightCm: Double
    let age: Int
    let gender: String
    let goal: String
    
    enum CodingKeys: String, CodingKey {
        case fullname = "full_name"
        case weightKg = "weight_kg"
        case heightCm = "height_cm"
        case age
        case gender
        case goal
    }
}

