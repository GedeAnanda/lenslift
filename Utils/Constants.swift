//
//  Constants.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 08/06/26.
//
import SwiftUI


// MARK: - API
struct Constants {
    static let baseURL = "http://192.168.1.23:8080"
    
//        static let baseURL = "http://127.0.0.1:8080"
}



// MARK: - Colors
extension Color {
    // Core
    static let lensGreen     = Color(red: 198/255, green: 255/255, blue: 0/255)
    static let lensSurface   = Color(red: 28/255,  green: 28/255,  blue: 30/255)
    static let lensSurface2  = Color(red: 44/255,  green: 44/255,  blue: 46/255)
    static let lensText      = Color(red: 142/255, green: 142/255, blue: 147/255)
    static let lensTextMuted = Color(red: 99/255,  green: 99/255,  blue: 102/255)

    // Macro
    static let lensMacroProtein = Color(red: 255/255, green: 107/255, blue: 107/255)
    static let lensMacroCarbs   = Color(red: 255/255, green: 217/255, blue: 61/255)
    static let lensMacroFat     = Color(red: 107/255, green: 203/255, blue: 119/255)
}

// MARK: - Placeholder View Modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
