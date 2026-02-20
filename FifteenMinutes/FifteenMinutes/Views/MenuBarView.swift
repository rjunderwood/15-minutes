import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    var timerManager: TimerManager
    var blockingManager: BlockingManager

    @Query(filter: #Predicate<FocusSession> { session in
        session.endTime != nil
    }, sort: \FocusSession.startTime, order: .reverse)
    private var allSessions: [FocusSession]

    private var todaySessions: [FocusSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return allSessions.filter { $0.startTime >= startOfDay }
    }

    var body: some View {
        VStack(spacing: 0) {
            switch timerManager.state {
            case .idle:
                idleView
            case .running:
                runningView
            case .completedAwaitingLog:
                completedView
            }

            Divider()

            bottomBar
        }
        .frame(width: 280)
    }

    private var idleView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("15 Minutes")
                    .font(.headline)
                Text("Stay focused, get things done")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 16)

            Button {
                timerManager.startSession(modelContext: modelContext)
                blockingManager.setSessionActive(true)
            } label: {
                Label("Start Focus Session", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 16)

            if !todaySessions.isEmpty {
                VStack(spacing: 4) {
                    Text("Today: \(todaySessions.count) session\(todaySessions.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(todaySessions.count * 15) minutes focused")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer().frame(height: 8)
        }
    }

    private var runningView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 16)

            Text(timerManager.formattedTimeRemaining)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .monospacedDigit()

            ProgressView(value: timerManager.progress)
                .tint(.accentColor)
                .padding(.horizontal, 24)

            Text("Stay focused!")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(role: .destructive) {
                blockingManager.setSessionActive(false)
                timerManager.cancelSession(modelContext: modelContext)
            } label: {
                Label("Cancel Session", systemImage: "xmark")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Spacer().frame(height: 8)
        }
    }

    private var completedView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 16)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Session Complete!")
                .font(.headline)

            Button {
                openWindow(id: "session-log")
            } label: {
                Label("Log What You Did", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 16)

            Spacer().frame(height: 8)
        }
    }

    private var bottomBar: some View {
        HStack {
            Button {
                openWindow(id: "daily-stats")
            } label: {
                Label("Stats", systemImage: "chart.bar")
            }
            .buttonStyle(.borderless)

            Spacer()

            Button {
                openWindow(id: "settings")
            } label: {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(.borderless)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
