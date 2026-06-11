//
//  AllSetStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct AllSetStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Celebration icon
            ZStack {
                Circle()
                    .fill(Color.lensGreen.opacity(0.12))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.lensGreen)
            }
            .padding(.bottom, 32)
            
            Text("You're all set,\n\(vm.name.isEmpty ? "champ" : vm.name)! 💪")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Here's your game plan:")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            // Summary cards
            HStack(spacing: 12) {
                SummaryPill(label: "Goal", value: vm.goal?.rawValue ?? "-")
                SummaryPill(label: "Level", value: vm.fitnessLevel?.rawValue ?? "-")
                SummaryPill(label: "Calories", value: "\(Int(vm.calorieTarget))")
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: onComplete) {
                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.lensGreen)
                        .cornerRadius(16)
                } else {
                    Text("Start Your Journey")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.lensGreen)
                        .cornerRadius(16)
                }
            }
            .disabled(vm.isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct SummaryPill: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.lensSurface))
    }
}
