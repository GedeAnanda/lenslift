//
//  BodyStatsStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct BodyStatsStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Body stats")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Used to calculate your daily calorie needs.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            VStack(spacing: 12) {
                StatInputField(label: "Age", value: $vm.age, unit: "years", keyboardType: .numberPad)
                StatInputField(label: "Height", value: $vm.heightCm, unit: "cm", keyboardType: .numberPad)
                StatInputField(label: "Weight", value: $vm.weightKg, unit: "kg", keyboardType: .decimalPad)
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
            Text("Calculate My Targets")
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

struct StatInputField: View {
    let label: String
    @Binding var value: String
    let unit: String
    let keyboardType: UIKeyboardType
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 8) {
                TextField("0", text: $value)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .focused($isFocused)
                    .frame(width: 80)
                
                Text(unit)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lensSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? Color.lensGreen.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}
