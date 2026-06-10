//
//  FoodModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

// MARK: - Request
struct FoodLogRequest: Codable {
    let foodName : String
    let calories : Double
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let logDate: String?
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case logDate = "log_date"
    }
}

// MARK : - Response
struct FoodLogResponse: Codable {
    let id: String
    let foodName: String
    let calories: Double
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let source: String
    let logDate: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case foodName = "food_name"
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case source
        case logDate = "log_date"
        case createdAt = "created_at"
    }
}


// MARK: - Daily Summary
struct DailySummary: Codable {
    let totalCalories: Double
    let targetCalories: Int
    let totalProteinG: Double
    let targetProteinG: Int
    let totalCarbsG: Double
    let totalFatG: Double
    
    enum CodingKeys: String, CodingKey {
        case totalCalories = "total_calories"
        case targetCalories = "target_calories"
        case totalProteinG = "total_protein_g"
        case targetProteinG = "target_protein_g"
        case totalCarbsG = "total_carbs_g"
        case totalFatG = "total_fat_g"
    }
}

struct FoodLogWithSummary: Codable {
    let foodLog: FoodLogResponse
    let dailySummary: DailySummary
    
    enum CodingKeys: String, CodingKey {
        case foodLog = "food_log"
        case dailySummary = "daily_summary"
    }
}

struct DailyFoodLogs: Codable {
    let logs: [FoodLogResponse]
    let dailySummary: DailySummary
    
    enum CodingKeys: String, CodingKey {
        case logs
        case dailySummary = "daily_summary"
    }
}

struct AIAnalyzeOnlyResponse: Codable {
    let foodName: String
    let calories: Double
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
    }
}


