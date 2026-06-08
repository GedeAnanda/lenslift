//
//  BodyWeightService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//


import Foundation

class BodyWeightService {
    static let shared = BodyWeightService()
    private init() {}
    
    private let api = APIService.shared
    
    //MARK: - Log Weight
    func logWeight(weightKg: Double, notes: String = "") async throws -> BodyWeightResponse {
        let body = BodyWeightRequest(weightKg: weightKg, notes: notes)
        return try await api.post(endpoint:"/body-weights", body: body)
    }
    
    // MARK : - Get History
    func getHistory()async throws -> [BodyWeightResponse] {
        return try await api.get(endpoint:"body-weights")
    }
    
    // MARK: - Get Latest
    func getLatest() async throws -> BodyWeightResponse {
        return try await api.get(endpoint: "/body-weights/latest")
    }
    
    // MARK: - Delete
    func deleteWeight(id: String) async throws {
        try await api.delete(endpoint: "/body-weights/\(id)")
    }
}


