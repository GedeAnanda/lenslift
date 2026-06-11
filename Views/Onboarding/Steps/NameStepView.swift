//
//  NameStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct NameStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            backButton
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What should\nwe call you?")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                TextField("", text: $vm.name)
                    .placeholder(when: vm.name.isEmpty) {
                        Text("Your name").foregroundColor(.white.opacity(0.3))
                    }
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .focused($isFocused)
                    .submitLabel(.next)
                    .onSubmit { if vm.canProceed { vm.next() } }
                
                Rectangle()
                    .fill(isFocused ? Color.lensGreen : Color.white.opacity(0.2))
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            nextButton
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .onAppear { isFocused = true }
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
