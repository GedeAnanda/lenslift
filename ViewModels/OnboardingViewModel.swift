//
//  OnboardingViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//

import SwiftUI
import Combine

enum FitnessGoal: String, CaseIterable {
    case loseFat = "Lose Fat"
    case buildMuscle = "Build Muscle"
    case maintain = "Maintain"
    
    var icon: String {
        switch self {
        case .loseFat: return "flame.fill"
        case .buildMuscle: return "dumbbell.fill"
        case .maintain: return "heart.fill"
        }
    }
    
    var description: String {
        switch self {
        case .loseFat: return "Burn calories & shed weight"
        case .buildMuscle: return "Gain strength & mass"
        case .maintain: return "Stay consistent & healthy"
        }
    }
}

enum FitnessLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .beginner: return "Less than 1 year training"
        case .intermediate: return "1–3 years training"
        case .advanced: return "3+ years training"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    let totalSteps = 7
    
    @Published var name: String = ""
    @Published var goal: FitnessGoal? = nil
    @Published var fitnessLevel: FitnessLevel? = nil
    
    @Published var age: String = ""
    @Published var heightCm: String = ""
    @Published var weightKg: String = ""
    
    @Published var calorieTarget: Double = 2000
    @Published var proteinTarget: Double = 150
    @Published var carbTarget: Double = 200
    @Published var fatTarget: Double = 65
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    var progress: Double {
        Double(currentStep) / Double(totalSteps - 1)
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return goal != nil
        case 3: return fitnessLevel != nil
        case 4: return !age.isEmpty && !heightCm.isEmpty && !weightKg.isEmpty
        case 5: return true
        case 6: return true
        default: return false
        }
    }
    
    func next() {
        if currentStep == 4 { calculateTargets() }
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep += 1
            }
        }
    }
    
    func back() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep -= 1
            }
        }
    }
    
    func calculateTargets() {
        guard let ageVal = Double(age),
              let height = Double(heightCm),
              let weight = Double(weightKg) else { return }
        
        let bmr = 10 * weight + 6.25 * height - 5 * ageVal + 5
        let tdee = bmr * 1.55
        
        switch goal {
        case .loseFat:
            calorieTarget = max(1200, tdee - 500)
        case .buildMuscle:
            calorieTarget = tdee + 300
        case .maintain, .none:
            calorieTarget = tdee
        }
        
        proteinTarget = weight * 2.0
        fatTarget = calorieTarget * 0.25 / 9
        let remainingCals = calorieTarget - (proteinTarget * 4) - (fatTarget * 9)
        carbTarget = max(50, remainingCals / 4)
        
        calorieTarget = (calorieTarget / 10).rounded() * 10
        proteinTarget = proteinTarget.rounded()
        carbTarget = carbTarget.rounded()
        fatTarget = fatTarget.rounded()
    }
    
    func completeOnboarding(completion: @escaping () -> Void) {
        isLoading = true
        
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(name, forKey: "onboardingName")
        
        Task {
            do {
                try await ProfileService.shared.updateProfile(
                    fullName: name,
                    weightKg: Double(weightKg) ?? 0,
                    heightCm: Double(heightCm) ?? 0,
                    age: Int(age) ?? 0,
                    gender: "male",
                    goal: goal?.rawValue ?? "Maintain"
                )
            } catch {
                // Non-critical, lanjut aja
            }
            
            await MainActor.run {
                isLoading = false
                completion()
            }
        }
    }
}
