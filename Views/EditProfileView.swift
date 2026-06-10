//
//  EditProfileView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 10/06/26.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var fullName = ""
    @State private var weightKg = ""
    @State private var heightCm = ""
    @State private var age = ""
    @State private var selectedGender = "male"
    @State private var selectedGoal = "maintain"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Edit Profile")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.lensTextMuted)
                        }
                    }
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        InputField(placeholder: "Full Name", text: $fullName)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("WEIGHT (kg)")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                InputField(placeholder: "72", text: $weightKg, keyboardType: .decimalPad)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("HEIGHT (cm)")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                InputField(placeholder: "173", text: $heightCm, keyboardType: .numberPad)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("AGE")
                                    .font(.system(size: 10))
                                    .tracking(1)
                                    .foregroundColor(.lensTextMuted)
                                InputField(placeholder: "19", text: $age, keyboardType: .numberPad)
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

                    Button {
                        Task {
                            guard let weight = Double(weightKg),
                                  let height = Double(heightCm),
                                  let ageInt = Int(age) else { return }
                            await viewModel.updateProfile(
                                fullName: fullName,
                                weightKg: weight,
                                heightCm: height,
                                age: ageInt,
                                gender: selectedGender,
                                goal: selectedGoal
                            )
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        } else {
                            Text("Save Changes")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                    }
                    .background(Color.lensGreen)
                    .cornerRadius(16)
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            fullName = viewModel.profile?.fullName ?? ""
            weightKg = String(format: "%.0f", viewModel.profile?.weightKg ?? 0)
            heightCm = String(format: "%.0f", viewModel.profile?.heightCm ?? 0)
            age = "\(viewModel.profile?.age ?? 0)"
            selectedGender = viewModel.profile?.gender ?? "male"
            selectedGoal = viewModel.profile?.goal ?? "maintain"
        }
    }
}
