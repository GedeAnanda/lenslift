//
//  AuthService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private init(){}
    
    private let api = APIService.shared
    
    //MARK: - Login
    func login (email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await api.post(
            endpoint:"auth/login",
            body: body,
            requiresAuth: false
        )
        api.token = response.accessToken
        return response
    }
    
    //MARK: - Register
    func register (fullName: String, email: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(fullName: fullName, email: email, password: password)
        let response: AuthResponse = try await api.post(
            endpoint:"auth/register",
            body: body,
            requiresAuth: false
        )
        api.token = response.accessToken
        return response
    }
    
    //MARK: - Logout
    func logout() {
        api.token = nil
    }
    
    //MARK: - Check Login
    var isLoggedIn: Bool {
        return api.token != nil
    }
    
}
