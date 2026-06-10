//
//  Home.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 10/06/26.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showLogoutConfirm = false
    @State private var showProgress = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                    // Avatar & Name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.lensSurface)
                                .frame(width: 80, height: 80)
                            Text(viewModel.profile?.fullName.prefix(1).uppercased() ?? "?")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.lensGreen)
                        }

                        Text(viewModel.profile?.fullName ?? "")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text(viewModel.profile?.goal.capitalized ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.lensTextMuted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.lensSurface)
                            .cornerRadius(20)
                    }

                    // Stats
                    HStack(spacing: 0) {
                        ProfileStat(value: String(format: "%.0f", viewModel.profile?.weightKg ?? 0), unit: "kg", label: "Weight")
                        Divider().background(Color.lensSurface2).frame(height: 40)
                        ProfileStat(value: String(format: "%.0f", viewModel.profile?.heightCm ?? 0), unit: "cm", label: "Height")
                        Divider().background(Color.lensSurface2).frame(height: 40)
                        ProfileStat(value: "\(viewModel.profile?.age ?? 0)", unit: "yrs", label: "Age")
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)

                    // Targets
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DAILY TARGETS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(viewModel.profile?.targetCalories ?? 0)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.lensGreen)
                                Text("kcal / day")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(viewModel.profile?.targetProteinG ?? 0)g")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("protein / day")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)

                    // Menu Items
                    VStack(spacing: 1) {
                        ProfileMenuItem(icon: "person.fill", title: "Edit Profile") {
                            showEditProfile = true
                        }
                        ProfileMenuItem(icon: "chart.line.uptrend.xyaxis", title: "Progress") {
                            showProgress = true
                        }
                        ProfileMenuItem(icon: "bell.fill", title: "Notifications") {}
                        ProfileMenuItem(icon: "questionmark.circle.fill", title: "Help & Support") {}
                    }
                    .background(Color.lensSurface)
                    .cornerRadius(16)

                    // Logout Button
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.lensSurface)
                        .cornerRadius(16)
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task { await viewModel.loadProfile() }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProgress) {
            ProgressTrackingView()
        }
        .confirmationDialog("Sign Out", isPresented: $showLogoutConfirm) {
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - ProfileStat
struct ProfileStat: View {
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
                    .padding(.bottom, 2)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.lensTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ProfileMenuItem
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.lensGreen)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}
