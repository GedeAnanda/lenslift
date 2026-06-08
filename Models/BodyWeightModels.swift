//
//  BodyWeightModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

// MARK: - Request
struct BodyWeightRequest: Codable {
    let weightKg: Double
    let notes: String
    
    enum CodingKeys: String, CodingKey {
        case weightKg = "weight_kg"
        case notes
    }
}

// MARK: - Response
struct BodyWeightResponse: Codable {
    let id: String
    let weightKg: Double
    let measuredDate: String
    let notes: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case weightKg = "weight_kg"
        case measuredDate = "measured_date"
        case notes
        case createdAt = "created_at"
    }
}
