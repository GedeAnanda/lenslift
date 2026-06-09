//
//  LogWeightView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI

struct LogWeightView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    @State private var weightInput = ""
    @State private var notes = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Log Weight")
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
                    HStack {
                        TextField("", text: $weightInput, prompt: Text("72.5").foregroundColor(.lensTextMuted))
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        Text("kg")
                            .font(.system(size: 24))
                            .foregroundColor(.lensTextMuted)
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(16)

                    InputField(placeholder: "Notes (optional)", text: $notes)
                }

                Spacer()

                Button {
                    guard let weight = Double(weightInput) else { return }
                    Task {
                        await viewModel.logWeight(weightKg: weight, notes: notes)
                        dismiss()
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .background(Color.lensGreen)
                .cornerRadius(16)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }
}
