//
//  OnboardingView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = ProfileViewModel()
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var age = ""
    @State private var selectedGender = "male"
    @State private var selectedGoal = "maintain"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Let's set up")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("your profile")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("This helps us calculate your daily targets.")
                            .font(.system(size: 14))
                            .foregroundColor(.lensTextMuted)
                    }
                    .padding(.top, 48)

                    // Body Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("BODY STATS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("WEIGHT")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                HStack {
                                    TextField("72", text: $weightKg)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("kg")
                                        .font(.system(size: 14))
                                        .foregroundColor(.lensTextMuted)
                                }
                                .padding()
                                .background(Color.lensSurface)
                                .cornerRadius(14)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("HEIGHT")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                HStack {
                                    TextField("173", text: $heightCm)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("cm")
                                        .font(.system(size: 14))
                                        .foregroundColor(.lensTextMuted)
                                }
                                .padding()
                                .background(Color.lensSurface)
                                .cornerRadius(14)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("AGE")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                HStack {
                                    TextField("19", text: $age)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("yrs")
                                        .font(.system(size: 14))
                                        .foregroundColor(.lensTextMuted)
                                }
                                .padding()
                                .background(Color.lensSurface)
                                .cornerRadius(14)
                            }
                        }
                    }

                    // Gender
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GENDER")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        HStack(spacing: 12) {
                            ForEach(["male", "female"], id: \.self) { gender in
                                Button {
                                    selectedGender = gender
                                } label: {
                                    Text(gender.capitalized)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(selectedGender == gender ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(selectedGender == gender ? Color.lensGreen : Color.lensSurface)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // Goal
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GOAL")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        HStack(spacing: 8) {
                            ForEach(["cut", "maintain", "bulk"], id: \.self) { goal in
                                Button {
                                    selectedGoal = goal
                                } label: {
                                    Text(goal.capitalized)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(selectedGoal == goal ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(selectedGoal == goal ? Color.lensGreen : Color.lensSurface)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // Target Preview
                    if viewModel.profile != nil {
                        VStack(spacing: 8) {
                            Text("YOUR DAILY TARGET")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)

                            HStack(spacing: 24) {
                                VStack(spacing: 4) {
                                    Text("\(viewModel.profile?.targetCalories ?? 0)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.lensGreen)
                                    Text("kcal")
                                        .font(.system(size: 13))
                                        .foregroundColor(.lensTextMuted)
                                }
                                Text("·")
                                    .foregroundColor(.lensTextMuted)
                                VStack(spacing: 4) {
                                    Text("\(viewModel.profile?.targetProteinG ?? 0)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("g protein")
                                        .font(.system(size: 13))
                                        .foregroundColor(.lensTextMuted)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.lensSurface)
                        .cornerRadius(16)
                    }

                    // Continue Button
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        } else {
                            Text("Continue")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                    }
                    .background(Color.lensGreen)
                    .cornerRadius(16)
                    .disabled(viewModel.isLoading)
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private func saveProfile() async {
        guard let weight = Double(weightKg),
              let height = Double(heightCm),
              let ageInt = Int(age) else { return }

        await viewModel.updateProfile(
            fullName: "",
            weightKg: weight,
            heightCm: height,
            age: ageInt,
            gender: selectedGender,
            goal: selectedGoal
        )

        if viewModel.profile != nil {
            await MainActor.run {
                authViewModel.isLoggedIn = true
            }
        }
    }
}
