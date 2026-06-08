//
//  AuthModels.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

//MARK: - Request

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case email
        case password
    }
}


// MARK: - Response
struct AuthResponse: Codable {
    let accessToken: String
    let user: UserProfile
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

struct UserProfile: Codable {
    let id: Int
    let fullName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
    }
}
