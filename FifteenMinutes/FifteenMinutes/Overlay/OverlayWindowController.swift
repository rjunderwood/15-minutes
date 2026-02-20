import AppKit
import SwiftUI

final class OverlayWindowController {
    private var windows: [NSWindow] = []

    func show() {
        guard windows.isEmpty else { return }

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.backgroundColor = .clear
            window.isOpaque = false
            window.ignoresMouseEvents = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.contentView = NSHostingView(rootView: OverlayContentView())
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }

    func dismissAll() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
    }
}
