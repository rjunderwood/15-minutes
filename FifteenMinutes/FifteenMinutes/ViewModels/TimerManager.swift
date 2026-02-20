import Foundation
import SwiftData

enum TimerState {
    case idle
    case running
    case completedAwaitingLog
}

@Observable
final class TimerManager {
    private(set) var state: TimerState = .idle
    private(set) var secondsRemaining: Int = 900
    private(set) var totalSeconds: Int = 900
    private(set) var currentSession: FocusSession?

    private var timer: Timer?
    var onSessionCompleted: (() -> Void)?

    var formattedTimeRemaining: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - secondsRemaining) / Double(totalSeconds)
    }

    var menuBarTitle: String {
        switch state {
        case .idle:
            return "15m"
        case .running:
            return formattedTimeRemaining
        case .completedAwaitingLog:
            return "15m \u{2713}"
        }
    }

    func startSession(modelContext: ModelContext) {
        guard state == .idle else { return }

        let session = FocusSession(startTime: .now, durationSeconds: totalSeconds)
        modelContext.insert(session)
        currentSession = session

        secondsRemaining = totalSeconds
        state = .running

        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func cancelSession(modelContext: ModelContext) {
        timer?.invalidate()
        timer = nil

        if let session = currentSession {
            modelContext.delete(session)
        }
        currentSession = nil
        state = .idle
        secondsRemaining = totalSeconds
    }

    func completeLog(description: String, modelContext: ModelContext) {
        guard state == .completedAwaitingLog, let session = currentSession else { return }
        session.workDescription = description
        session.endTime = .now
        try? modelContext.save()
        currentSession = nil
        state = .idle
        secondsRemaining = totalSeconds
    }

    private func tick() {
        guard state == .running else { return }
        secondsRemaining -= 1

        if secondsRemaining <= 0 {
            secondsRemaining = 0
            timer?.invalidate()
            timer = nil
            state = .completedAwaitingLog
            onSessionCompleted?()
        }
    }
}
