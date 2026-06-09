//
//  AuthViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    init() {
        isLoggedIn = AuthService.shared.isLoggedIn
    }
    
    // MARK: - Login
    func login (email: String, password: String) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            _ = try await AuthService.shared.login(email: email, password: password)
            await MainActor.run {
                isLoading = false
                isLoggedIn = true
            }
        } catch APIError.serverError(let message) {
            await MainActor.run {
                 isLoading = false
                 errorMessage  = message
                 showError = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage  = "Terjadi kesalahan, coba lagi"
                showError = true
            }
        }
    }
    
    // MARK: - Register
    func register(fullName: String, email: String, password: String) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            _ = try await AuthService.shared.register(fullName: fullName, email: email, password: password)
            await MainActor.run {
                isLoading = false
                isLoggedIn = true
            }
        }  catch APIError.serverError(let message) {
            await MainActor.run {
                isLoading = false
                errorMessage  = message
                showError = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Terjadi kesalahan, coba lagi"
                showError = true
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        AuthService.shared.logout()
        isLoggedIn = false
    }
}
