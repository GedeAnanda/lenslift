//
//  ContentView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }
            WorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            ProgressTrackingView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(.lensGreen)
        .preferredColorScheme(.dark)
    }
}
