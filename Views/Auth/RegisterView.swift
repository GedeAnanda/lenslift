//
//  RegisterView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.lensGreen)
                        .font(.system(size: 16))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.5)

                    VStack(spacing: 12) {
                        TextField("", text: $fullName, prompt: Text("Full Name").foregroundColor(.lensTextMuted))
                            .padding()
                            .background(Color.lensSurface)
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        TextField("", text: $email, prompt: Text("Email Address").foregroundColor(.lensTextMuted))
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
                    }

                    Button {
                        Task {
                            await authViewModel.register(
                                fullName: fullName,
                                email: email,
                                password: password
                            )
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        } else {
                            Text("Get Started")
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
                        Spacer()
                        Text("Already have an account?")
                            .font(.system(size: 13))
                            .foregroundColor(.lensTextMuted)
                        Button {
                            dismiss()
                        } label: {
                            Text("Sign In")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.lensGreen)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK") { authViewModel.showError = false }
        } message: {
            Text(authViewModel.errorMessage)
        }
    }
}
