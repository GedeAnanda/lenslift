//
//  WelcomeStepView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import Foundation
import SwiftUI

struct WelcomeStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo / icon area
            ZStack {
                Circle()
                    .fill(Color.lensGreen.opacity(0.12))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Color.lensGreen)
            }
            .padding(.bottom, 40)
            
            Text("LensLift")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text("Your AI-powered\ngym companion.")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            
            Spacer()
            
            // CTA
            Button(action: { vm.next() }) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.lensGreen)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            Text("Already have an account? Sign in")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 16)
                .padding(.bottom, 40)
        }
    }
}
