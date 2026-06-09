//
//  APIService.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation

// MARK: - Error
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
}


// MARK: - APIService
class APIService {
    static let shared = APIService()
    private init(){}
    
    private let baseURL = Constants.baseURL
    
    // MARK: - Token
    var token: String? {
        get {UserDefaults.standard.string(forKey: "access_token")}
        set {UserDefaults.standard.set(newValue, forKey: "access_token")}
    }
    
    // MARK: -Request Builder
    private func makeRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = token else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - GET
    func get<T: Codable> (endpoint: String) async throws -> T {
        let request = try makeRequest(endpoint: endpoint, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorResponse = try? JSONDecoder().decode([String : String].self, from: data)
            throw APIError.serverError(errorResponse?["message"] ?? "Server error")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("GET RAW RESPONSE [\(endpoint)]: \(jsonString)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("GET DECODE ERROR [\(endpoint)]: \(error)")
            throw APIError.decodingError
        }
    }
    
    
    // MARK: -POST
    func post <T:Codable> (endpoint: String, body: Codable, requiresAuth: Bool = true) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let request = try makeRequest(endpoint: endpoint, method:"POST", body: bodyData,requiresAuth: requiresAuth)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorResponse = try? JSONDecoder().decode([String : String].self, from: data)
            throw APIError.serverError(errorResponse?["message"] ?? "Server error")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("RAW RESPONSE: \(jsonString)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("DECODE ERROR: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: -PUT
    func put<T:Codable>(endpoint:String, body: Codable) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let request = try makeRequest(endpoint: endpoint, method: "PUT", body: bodyData)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode ) {
            let errorResponse = try? JSONDecoder().decode([String : String].self, from: data)
            throw APIError.serverError(errorResponse?["message"] ?? "Server error")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
        
    }
    
    // MARK: - DELETE
    func delete(endpoint: String) async throws {
        let request = try makeRequest(endpoint: endpoint, method: "DELETE")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode ) {
            let errorResponse = try? JSONDecoder().decode([String : String].self, from: data)
            throw APIError.serverError(errorResponse?["message"] ?? "Server error")
        }
    }
}


