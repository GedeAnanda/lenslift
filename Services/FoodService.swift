import Foundation

class FoodService {
    static let shared = FoodService()
    private init() {}
    private let api = APIService.shared

    func addFoodLog(
        foodName: String,
        calories: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double
    ) async throws -> FoodLogWithSummary {
        let body = FoodLogRequest(
            foodName: foodName,
            calories: calories,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            logDate: nil
        )
        return try await api.post(endpoint: "/api/food-logs", body: body)
    }

    func getDailyLogs(date: String? = nil) async throws -> DailyFoodLogs {
        var endpoint = "/api/food-logs"
        if let date = date {
            endpoint += "?date=\(date)"
        }
        return try await api.get(endpoint: endpoint)
    }

    func deleteFoodLog(id: String) async throws {
        try await api.delete(endpoint: "/api/food-logs/\(id)")
    }

    func analyzeOnly(imageData: Data) async throws -> FoodLogResponse {
        guard let url = URL(string: "\(Constants.baseURL)/api/food-logs/analyze-only") else {
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

        if let jsonString = String(data: body, encoding: .utf8) {
            print("ANALYZE ONLY REQUEST to: \(url)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("ANALYZE ONLY RESPONSE: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let errorStr = String(data: data, encoding: .utf8) ?? "unknown"
            print("ANALYZE ONLY ERROR: \(errorStr)")
            throw APIError.serverError("Gagal analisis foto")
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

        let aiResult = try JSONDecoder().decode(AIAnalyzeOnlyResponse.self, from: data)

        return FoodLogResponse(
            id: UUID().uuidString,
            foodName: aiResult.foodName,
            calories: aiResult.calories,
            proteinG: aiResult.proteinG,
            carbsG: aiResult.carbsG,
            fatG: aiResult.fatG,
            source: "ai_photo",
            logDate: "",
            createdAt: ""
        )
    }
}
