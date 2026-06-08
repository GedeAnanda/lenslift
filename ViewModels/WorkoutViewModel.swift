//
//  WorkoutViewModel.swift
//  LensLift
//
//  Created by I Gede Ananda Bela Persada on 09/06/26.
//

class WorkoutViewModel: ObservableObject {
    @Published var templates: [WorkoutTemplateListResponse] = []
    @Published var activeSession: SessionResponse?
    @Published var sessionLogs: [SessionLogResponse] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var elapsedSeconds = 0
    
    private let workoutService = WorkoutService.shared
    private var timer: Timer?

    // MARK: - Templates
    func loadTemplates() async {
        await setLoading(true)
        do {
            let result = try await workoutService.getTemplates()
            await MainActor.run {
                templates = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal load templates")
            }
        }
    }
    
    func createTemplate(
        name: String,
        description: String,
        exercises: [ExerciseRequest]
    ) async {
        await setLoading(true)
        do {
            _ = try await workoutService.createTemplate(
                name: name,
                description: description,
                exercises: exercises
            )
            await loadTemplates()
        } catch APIError.serverError(let message) {
            await MainActor.run {
                isLoading = false
                showErrorMessage(message)
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal buat template")
            }
        }
    }

    
    func updateTemplate(
        id: String,
        name: String,
        description: String,
        exercises: [ExerciseRequest]
    ) async {
        await setLoading(true)
        do {
            _ = try await workoutService.updateTemplate(
                id: id,
                name: name,
                description: description,
                exercises: exercises
            )
            await loadTemplates()
        } catch APIError.serverError(let message) {
            await MainActor.run {
                isLoading = false
                showErrorMessage(message)
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showErrorMessage("Gagal update template")
            }
        }
    }
    
    func deleteTemplate(id: String) async {
        do {
            try await workoutService.deleteTemplate(id: id)
            await loadTemplates()
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal hapus template")
            }
        }
    }
    
    // MARK: - Sessions
    func startSession(templateId: String? = nil) async {
        do {
            let session = try await workoutService.startSession(templateId: templateId)
            await MainActor.run {
                activeSession = session
                sessionLogs = []
                elapsedSeconds = 0
                startTimer()
            }
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal mulai sesi")
            }
        }
    }
    
    func logSet(
        exerciseName: String,
        setNumber: Int,
        actualReps: Int,
        actualWeightKg: Double
    ) async {
        guard let sessionId = activeSession?.id else { return }
        do {
            let log = try await workoutService.logSet(
                sessionId: sessionId,
                exerciseName: exerciseName,
                setNumber: setNumber,
                actualReps: actualReps,
                actualWeightKg: actualWeightKg
            )
            await MainActor.run {
                sessionLogs.append(log)
            }
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal log set")
            }
        }
    }
    
    func endSession() async -> SessionDetailResponse? {
        guard let sessionId = activeSession?.id else { return nil }
        do {
            let detail = try await workoutService.endSession(sessionId: sessionId)
            await MainActor.run {
                activeSession = nil
                sessionLogs = []
                stopTimer()
            }
            return detail
        } catch {
            await MainActor.run {
                showErrorMessage("Gagal end sesi")
            }
            return nil
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                self.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedSeconds = 0
    }

    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var isSessionActive: Bool {
        activeSession != nil
    }

    // MARK: - Helpers
    @MainActor
    private func setLoading(_ value: Bool) {
        isLoading = value
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
}
