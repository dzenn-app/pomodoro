import Cocoa
import Combine
import SwiftUI

@MainActor
final class WindowManager: ObservableObject {
    static let shared = WindowManager()
    let objectWillChange = ObservableObjectPublisher()
    var floatingWindow: NSWindow?
    var mainWindow: NSWindow?

    func showFloating() {
        if floatingWindow != nil { return }

        objectWillChange.send()
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
        window.level = .floating
        window.hidesOnDeactivate = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        window.contentView = NSHostingView(rootView: contentView)
        window.orderFrontRegardless()

        floatingWindow = window
    }

    func hideFloating() {
        guard floatingWindow != nil else { return }
        objectWillChange.send()
        floatingWindow?.orderOut(nil)
        floatingWindow = nil
    }

    func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if mainWindow == nil {
            mainWindow = makeMainWindow()
        }
        mainWindow?.deminiaturize(nil)
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    private func makeMainWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 420),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Dzenn"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: MainView())
        return window
    }
}
