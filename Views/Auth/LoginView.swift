//
//  LoginView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 8) {
                        Text("LENSLIFT")
                            .font(.system(size: 36, weight: .ultraLight))
                            .tracking(12)
                            .foregroundColor(.white)

                        Text("YOUR GYM. TRACKED.")
                            .font(.system(size: 11, weight: .regular))
                            .tracking(4)
                            .foregroundColor(.lensTextMuted)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.lensTextMuted))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.lensSurface)
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.lensTextMuted))
                            .padding()
                            .background(Color.lensSurface)
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        Button {
                            Task { await authViewModel.login(email: email, password: password) }
                        } label: {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                        }
                        .background(Color.lensGreen)
                        .cornerRadius(16)
                        .disabled(authViewModel.isLoading)

                        HStack {
                            Rectangle().frame(height: 0.5).foregroundColor(.lensSurface2)
                            Text("or").font(.system(size: 13)).foregroundColor(.lensTextMuted)
                            Rectangle().frame(height: 0.5).foregroundColor(.lensSurface2)
                        }
                        .padding(.vertical, 4)

                        Button {
                            showRegister = true
                        } label: {
                            Text("Create Account")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.lensSurface2, lineWidth: 0.5)
                                )
                        }

                        Button {
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 13))
                                .foregroundColor(.lensTextMuted)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .alert("Error", isPresented: $authViewModel.showError) {
                Button("OK") { authViewModel.showError = false }
            } message: {
                Text(authViewModel.errorMessage)
            }
        }
    }
}
