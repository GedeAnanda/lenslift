//
//  FoodService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class FoodService {
    static let shared = FoodService()
    
    private init() { }
    
    private let api = APIService.shared
    
    //MARK: - Add Manual
    func addFoodLog(
        foodName:String,
        calories:Double,
        proteinG:Double,
        carbsG:Double,
        fatG: Double,
    ) async throws -> FoodLogWithSummary {
        let body  = FoodLogRequest(
            foodName: foodName,
            calories: calories,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG
        )
        return try await api.post(
            endpoint:"/food-logs", body: body
        )
    }
    
    //MARK: - Get Daily Logs
    func getDailyLogs(date: String? = nil) async throws -> DailyFoodLog {
        var endpoint = "/food-logs"
        if let date = date {
            endpoint += "?date=\(date)"
        }
        return try await api.get(endpoint: endpoint)
    }
    
    //MARK: - Delete Food Log
    func deleteFoodLog(id: String) async throws -> {
        try await api.delete(endpoint:"food-logs/\(id)")
    }
    
    // MARK: - Analyze Food (AI)
    func analyzeFood(imageData: Data) async throws -> FoodLogWithSummary {
        guard let url = URL(string: "\(Constants.baseURL)/food-logs/analyze") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
    
        if let token = api.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"food.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Gagal analisis foto")
        }
        return try JSONDecoder().decode(FoodLogWithSummary.self, from: data)
        }
    
}

