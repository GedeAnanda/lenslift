//
//  AddFoodView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var foodName = ""
    @State private var calories = ""
    @State private var proteinG = ""
    @State private var carbsG = ""
    @State private var fatG = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Add Food")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.lensTextMuted)
                            .font(.system(size: 16))
                    }
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    InputField(placeholder: "Food Name", text: $foodName)
                    InputField(placeholder: "Calories (kcal)", text: $calories, keyboardType: .decimalPad)
                    InputField(placeholder: "Protein (g)", text: $proteinG, keyboardType: .decimalPad)
                    InputField(placeholder: "Carbs (g)", text: $carbsG, keyboardType: .decimalPad)
                    InputField(placeholder: "Fat (g)", text: $fatG, keyboardType: .decimalPad)
                }

                Button {
                    Task {
                        await viewModel.addFoodLog(
                            foodName: foodName,
                            calories: Double(calories) ?? 0,
                            proteinG: Double(proteinG) ?? 0,
                            carbsG: Double(carbsG) ?? 0,
                            fatG: Double(fatG) ?? 0
                        )
                        dismiss()
                    }
                } label: {
                    Text("Add to Log")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .background(Color.lensGreen)
                .cornerRadius(16)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.lensTextMuted))
            .keyboardType(keyboardType)
            .padding()
            .background(Color.lensSurface)
            .cornerRadius(14)
            .foregroundColor(.white)
    }
}
