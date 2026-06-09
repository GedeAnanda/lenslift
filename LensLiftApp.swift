//
//  LensLiftApp.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import Foundation
import SwiftUI

@main
struct LensLiftApp: App {
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
