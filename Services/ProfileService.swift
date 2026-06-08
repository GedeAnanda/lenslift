//
//  ProfileService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let api = APIService.shared
    
    //MARK: - Get Profile
    func getProfile() async throws -> ProfileResponse {
        return try await api.get(endpoint: "/profile")
    }
    
    //MARK: - Update Profile
    func updateProfile(
        fullName:String,
        weightKg:Double,
        heightCm:Double,
        age:Int,
        gender:String,
        goal:String
    ) async throws -> ProfileResponse {
        let body = UpdateProfileRequest(
            fullName: fullName,
            weightKg: weightKg,
            heightCm: heightCm,
            age: age,
            gender: gender,
            goal: goal
        )
        return try await api.put(endpoint: "/profile", body: body)
    }
}
