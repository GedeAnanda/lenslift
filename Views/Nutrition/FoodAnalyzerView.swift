//
//  FoodAnalyzerView.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

import SwiftUI
import PhotosUI

struct FoodAnalyzerView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.lensGreen)
                    }
                    Spacer()
                }
                .padding(.top, 16)

                Text("Scan Food")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Point your camera at a meal for instant macros.")
                    .font(.system(size: 14))
                    .foregroundColor(.lensTextMuted)

                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .cornerRadius(16)
                        .clipped()

                    Button {
                        Task {
                            await viewModel.analyzeFood(imageData: imageData)
                            dismiss()
                        }
                    } label: {
                        Text("Analyze Food")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .background(Color.lensGreen)
                    .cornerRadius(16)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.lensSurface2, style: StrokeStyle(lineWidth: 1, dash: [8]))
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                            .background(Color.lensSurface.cornerRadius(16))

                        VStack(spacing: 12) {
                            Image(systemName: "camera")
                                .font(.system(size: 40))
                                .foregroundColor(.lensTextMuted)
                            Text("Point at your food")
                                .font(.system(size: 14))
                                .foregroundColor(.lensTextMuted)
                        }
                    }
                }

                Text("— OR —")
                    .font(.system(size: 13))
                    .foregroundColor(.lensTextMuted)
                    .frame(maxWidth: .infinity, alignment: .center)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Library")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.lensSurface)
                    .cornerRadius(12)
                }
                .onChange(of: selectedPhoto) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
