import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var floatingWindow: NSWindow?

    // func applicationDidFinishLaunching(_ notification: Notification) {
    //     createFloatingWindow()
    // }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func createFloatingWindow() {
        let contentView = FloatingTimerView()

        let window = NSPanel(
            contentRect: NSRect(x: 100, y: 600, width: 260, height: 90),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating   // 👈 always on top
        window.hidesOnDeactivate = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        window.contentView = NSHostingView(rootView: contentView)
        window.orderFrontRegardless()

        self.floatingWindow = window
    }
}
