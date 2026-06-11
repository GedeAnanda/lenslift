//
//  OnboardingView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar (hidden di step 0 dan 6)
                if vm.currentStep > 0 && vm.currentStep < 6 {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity)
                }
                
                // Step content
                TabView(selection: $vm.currentStep) {
                    WelcomeStepView(vm: vm).tag(0)
                    NameStepView(vm: vm).tag(1)
                    GoalStepView(vm: vm).tag(2)
                    FitnessLevelStepView(vm: vm).tag(3)
                    BodyStatsStepView(vm: vm).tag(4)
                    DailyTargetsStepView(vm: vm).tag(5)
                    AllSetStepView(vm: vm) {
                        vm.completeOnboarding {
                            hasCompletedOnboarding = true
                        }
                    }.tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: vm.currentStep)
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 3)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.lensGreen)
                    .frame(width: geo.size.width * vm.progress, height: 3)
                    .animation(.easeInOut(duration: 0.35), value: vm.progress)
            }
        }
        .frame(height: 3)
        .padding(.bottom, 8)
    }
}
