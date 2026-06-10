import SwiftUI
import PhotosUI

struct FoodAnalyzerView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedUIImage: UIImage?
    @State private var analyzeResult: FoodLogWithSummary?
    @State private var showResult = false
    @State private var isAnalyzing = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showResult, let result = analyzeResult {
                AIResultView(
                    result: result,
                    onAddToLog: {
                        Task {
                            await viewModel.addFoodLog(
                                foodName: result.foodLog.foodName,
                                calories: result.foodLog.calories,
                                proteinG: result.foodLog.proteinG,
                                carbsG: result.foodLog.carbsG,
                                fatG: result.foodLog.fatG
                            )
                            dismiss()
                        }
                    },
                    onDismiss: { dismiss() },
                    onRetry: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showResult = false
                            analyzeResult = nil
                            selectedImageData = nil
                            selectedUIImage = nil
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))

            } else if isAnalyzing {
                AnalyzingView(image: selectedUIImage)
                    .transition(.opacity)

            } else {
                ScanInputView(
                    selectedPhoto: $selectedPhoto,
                    selectedUIImage: selectedUIImage,
                    onAnalyze: {
                        guard let imageData = selectedImageData else { return }
                        Task { await startAnalyze(imageData: imageData) }
                    },
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showResult)
        .animation(.easeInOut(duration: 0.35), value: isAnalyzing)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    selectedUIImage = UIImage(data: data)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private func startAnalyze(imageData: Data) async {
        await MainActor.run {
            isAnalyzing = true
        }

        do {
            let foodLog = try await FoodService.shared.analyzeOnly(imageData: imageData)
            try? await Task.sleep(nanoseconds: 800_000_000)

            let currentSummary = await MainActor.run {
                viewModel.dailyLogs?.dailySummary ?? DailySummary(
                    totalCalories: 0,
                    targetCalories: 3051,
                    totalProteinG: 0,
                    targetProteinG: 144,
                    totalCarbsG: 0,
                    totalFatG: 0
                )
            }

            await MainActor.run {
                analyzeResult = FoodLogWithSummary(
                    foodLog: foodLog,
                    dailySummary: currentSummary
                )
                isAnalyzing = false
            }

            try? await Task.sleep(nanoseconds: 100_000_000)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showResult = true
                }
            }

        } catch {
            await MainActor.run {
                isAnalyzing = false
                viewModel.errorMessage = "Gagal analisis foto, coba lagi"
                viewModel.showError = true
            }
        }
    }
}

struct AnalyzingView: View {
    let image: UIImage?
    @State private var rotation: Double = 0
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            if let image = image {
                ZStack {
                    Circle()
                        .stroke(Color.lensGreen.opacity(0.2), lineWidth: 3)
                        .frame(width: 260, height: 260)
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.lensGreen.opacity(0.1), Color.lensGreen]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: rotation)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 230, height: 230)
                        .clipShape(Circle())
                }
            }

            VStack(spacing: 10) {
                Text("Analyzing your food...")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Text("AI is identifying calories and macros")
                    .font(.system(size: 14))
                    .foregroundColor(.lensTextMuted)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            rotation = 360
            pulse = true
        }
    }
}

struct ScanInputView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    let selectedUIImage: UIImage?
    let onAnalyze: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button { onDismiss() } label: {
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
            .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Scan Food")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Take a photo of your meal for instant nutrition breakdown.")
                            .font(.system(size: 14))
                            .foregroundColor(.lensTextMuted)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.lensSurface)
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)

                        if let image = selectedUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 260)
                                .cornerRadius(20)
                                .clipped()

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Change")
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(20)
                                    }
                                    .padding(12)
                                }
                            }
                            .frame(height: 260)
                        } else {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.lensSurface2)
                                        .frame(width: 64, height: 64)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.lensTextMuted)
                                }
                                Text("Point at your food")
                                    .font(.system(size: 15))
                                    .foregroundColor(.lensTextMuted)
                                Text("Choose a clear, well-lit photo\nfor best results")
                                    .font(.system(size: 12))
                                    .foregroundColor(.lensTextMuted)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    if selectedUIImage == nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TIPS FOR BEST RESULTS")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.lensTextMuted)
                            TipRow(text: "Take photo from directly above the food")
                            TipRow(text: "Make sure all food items are visible")
                            TipRow(text: "Good lighting gives better accuracy")
                            TipRow(text: "One dish per photo works best")
                        }
                        .padding(16)
                        .background(Color.lensSurface)
                        .cornerRadius(14)
                    }

                    VStack(spacing: 12) {
                        if selectedUIImage != nil {
                            Button { onAnalyze() } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                    Text("Analyze with AI")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                            .background(Color.lensGreen)
                            .cornerRadius(16)
                        }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                Text(selectedUIImage == nil ? "Choose from Library" : "Choose Different Photo")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selectedUIImage == nil ? .white : .lensTextMuted)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.lensSurface)
                            .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct AIResultView: View {
    let result: FoodLogWithSummary
    let onAddToLog: () -> Void
    let onDismiss: () -> Void
    let onRetry: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { onRetry() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Scan Again")
                    }
                    .foregroundColor(.lensGreen)
                    .font(.system(size: 16))
                }
                Spacer()
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.lensTextMuted)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.lensGreen)
                        Text("Food analyzed successfully!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.lensGreen.opacity(0.12))
                    .cornerRadius(12)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(result.foodLog.foodName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(Int(result.foodLog.calories))")
                                .font(.system(size: 52, weight: .bold))
                                .foregroundColor(.lensGreen)
                            Text("kcal")
                                .font(.system(size: 20))
                                .foregroundColor(.lensTextMuted)
                                .padding(.bottom, 8)
                            Spacer()
                            Text("AI")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.lensGreen)
                                .cornerRadius(6)
                        }
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("NUTRITION BREAKDOWN")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)
                        MacroDetailRow(name: "Protein", value: result.foodLog.proteinG, unit: "g", color: .lensGreen, description: "Builds & repairs muscle")
                        Divider().background(Color.lensSurface2)
                        MacroDetailRow(name: "Carbohydrates", value: result.foodLog.carbsG, unit: "g", color: .blue, description: "Primary energy source")
                        Divider().background(Color.lensSurface2)
                        MacroDetailRow(name: "Fat", value: result.foodLog.fatG, unit: "g", color: .orange, description: "Hormones & vitamin absorption")
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("TODAY'S TOTALS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(.lensTextMuted)
                        DailySummaryRow(label: "Calories", current: result.dailySummary.totalCalories, target: Double(result.dailySummary.targetCalories), unit: "kcal", color: .lensGreen)
                        DailySummaryRow(label: "Protein", current: result.dailySummary.totalProteinG, target: Double(result.dailySummary.targetProteinG), unit: "g", color: .lensGreen)
                        DailySummaryRow(label: "Carbs", current: result.dailySummary.totalCarbsG, target: 200, unit: "g", color: .blue)
                        DailySummaryRow(label: "Fat", current: result.dailySummary.totalFatG, target: 80, unit: "g", color: .orange)
                    }
                    .padding(20)
                    .background(Color.lensSurface)
                    .cornerRadius(20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 40)

                    VStack(spacing: 10) {
                        Button { onAddToLog() } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to My Log")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .background(Color.lensGreen)
                        .cornerRadius(16)

                        Button { onDismiss() } label: {
                            Text("Just checking — don't add")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.lensTextMuted)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .background(Color.lensSurface)
                        .cornerRadius(14)
                    }
                    .opacity(appeared ? 1 : 0)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct TipRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.lensGreen)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.lensText)
        }
    }
}

struct MacroDetailRow: View {
    let name: String
    let value: Double
    let unit: String
    let color: Color
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(format: "%.0f", value))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.lensTextMuted)
            }
            Spacer()
            Text("\(String(format: "%.1f", value))\(unit)")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(color)
        }
    }
}

struct DailySummaryRow: View {
    let label: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.lensText)
                Spacer()
                Text("\(Int(current)) / \(Int(target)) \(unit)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .frame(height: 6)
                        .foregroundColor(.lensSurface2)
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: geo.size.width * progress, height: 6)
                        .foregroundColor(color)
                }
            }
            .frame(height: 6)
        }
    }
}
