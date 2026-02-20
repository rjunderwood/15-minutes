import SwiftUI
import SwiftData

@main
struct FifteenMinutesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var timerManager = TimerManager()
    @State private var blockingManager = BlockingManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([FocusSession.self, BlockedApp.self])
        let config = ModelConfiguration("FifteenMinutes", isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(timerManager: timerManager, blockingManager: blockingManager)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    setupTimerCallbacks()
                    loadBlockedApps()
                }
        } label: {
            Label(timerManager.menuBarTitle, systemImage: "timer")
                .labelStyle(.titleOnly)
        }
        .menuBarExtraStyle(.window)

        Window("Log Session", id: "session-log") {
            SessionLogView(timerManager: timerManager)
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Window("Daily Stats", id: "daily-stats") {
            DailyStatsView()
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
        .defaultPosition(.center)

        Window("Settings", id: "settings") {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    private func setupTimerCallbacks() {
        timerManager.onSessionCompleted = { [self] in
            blockingManager.setSessionActive(false)
            NotificationManager.shared.sendSessionCompleteNotification()
        }

        appDelegate.onNotificationAction = {
            if let keyWindow = NSApplication.shared.keyWindow {
                keyWindow.makeKeyAndOrderFront(nil)
            }
        }
    }

    private func loadBlockedApps() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<BlockedApp>()
        if let apps = try? context.fetch(descriptor) {
            blockingManager.updateBlockedApps(apps)
        }
    }
}
