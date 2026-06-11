//
//  DailyTargetsStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct DailyTargetsStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your daily\ntargets")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Calculated based on your stats & goal. Adjust anytime.")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // Calorie card
                    VStack(spacing: 8) {
                        HStack {
                            Text("Calories")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("\(Int(vm.calorieTarget)) kcal")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(Color.lensGreen)
                        }
                        
                        Slider(value: $vm.calorieTarget, in: 1200...4000, step: 50)
                            .tint(Color.lensGreen)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.lensSurface))
                    
                    // Macros
                    VStack(spacing: 16) {
                        MacroSlider(label: "Protein", value: $vm.proteinTarget, range: 50...300, unit: "g", color: Color.lensMacroProtein)
                        MacroSlider(label: "Carbs", value: $vm.carbTarget, range: 50...500, unit: "g", color: Color.lensMacroCarbs)
                        MacroSlider(label: "Fat", value: $vm.fatTarget, range: 20...150, unit: "g", color: Color.lensMacroFat)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.lensSurface))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .overlay(alignment: .bottom) {
            nextButton
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
        }
    }
    
    private var backButton: some View {
        Button(action: { vm.back() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    private var nextButton: some View {
        Button(action: { vm.next() }) {
            Text("Looks Good!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.lensGreen)
                .cornerRadius(16)
        }
    }
}

struct MacroSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("\(Int(value))\(unit)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: 5)
                .tint(color)
        }
    }
}
