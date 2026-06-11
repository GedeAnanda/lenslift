//
//  SplashView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 11/06/26.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var isFinished = false
    
    var body: some View {
        if isFinished {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image("LensLift-AppIcon-1024")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("LensLift")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                    textOpacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0
                        textOpacity = 0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    isFinished = true
                }
            }
        }
    }
}
