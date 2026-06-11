//
//  GoalStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct GoalStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            Spacer()
            
            Text("What's your\nmain goal?")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: vm.goal == goal,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.goal = goal
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            nextButton
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }
    
    private var backButton: some View {
        Button(action: { vm.back() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var nextButton: some View {
        Button(action: { vm.next() }) {
            Text("Continue")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(vm.canProceed ? .black : .white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(vm.canProceed ? Color.lensGreen : Color.white.opacity(0.1))
                .cornerRadius(16)
        }
        .disabled(!vm.canProceed)
        .animation(.easeInOut(duration: 0.2), value: vm.canProceed)
    }
}

struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.lensGreen : Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .black : .white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(goal.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.lensGreen)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.lensGreen.opacity(0.1) : Color.lensSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.lensGreen : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
