//
//  ProfileViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileResponse?
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let profileService = ProfileService.shared

    func loadProfile() async {
        do {
            let result = try await profileService.getProfile()
            await MainActor.run { profile = result }
        } catch {
            print("Error load profile: \(error)")
        }
    }

    func updateProfile(
        fullName: String,
        weightKg: Double,
        heightCm: Double,
        age: Int,
        gender: String,
        goal: String
    ) async {
        await MainActor.run { isLoading = true }
        do {
            let result = try await profileService.updateProfile(
                fullName: fullName,
                weightKg: weightKg,
                heightCm: heightCm,
                age: age,
                gender: gender,
                goal: goal
            )
            await MainActor.run {
                profile = result
                isLoading = false
            }
        } catch {
            await MainActor.run { isLoading = false }
            print("Error update profile: \(error)")
        }
    }
}
