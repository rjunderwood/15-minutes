import AppKit
import SwiftData

@Observable
final class BlockingManager {
    private(set) var isSessionActive = false
    private var blockedBundleIDs: Set<String> = []
    private var workspaceObserver: Any?
    private let overlayController = OverlayWindowController()

    func updateBlockedApps(_ apps: [BlockedApp]) {
        blockedBundleIDs = Set(apps.map { $0.bundleIdentifier })
    }

    func setSessionActive(_ active: Bool) {
        isSessionActive = active

        if active {
            startObserving()
            checkCurrentApp()
        } else {
            stopObserving()
            overlayController.dismissAll()
        }
    }

    private func startObserving() {
        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppActivation(notification)
        }
    }

    private func stopObserving() {
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            workspaceObserver = nil
        }
    }

    private func handleAppActivation(_ notification: Notification) {
        guard isSessionActive else { return }
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier else { return }

        if blockedBundleIDs.contains(bundleID) {
            overlayController.show()
        } else {
            overlayController.dismissAll()
        }
    }

    private func checkCurrentApp() {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = frontApp.bundleIdentifier else { return }

        if blockedBundleIDs.contains(bundleID) {
            overlayController.show()
        }
    }

    deinit {
        stopObserving()
    }
}
