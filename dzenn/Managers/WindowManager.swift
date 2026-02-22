import Cocoa
import Combine
import SwiftUI

@MainActor
final class WindowManager: ObservableObject {
    static let shared = WindowManager()
    let objectWillChange = ObservableObjectPublisher()

    private enum MainWindowChrome {
        static let trafficLightsHorizontalOffset: CGFloat = 6
        static let trafficLightsVerticalOffset: CGFloat = -6
    }
    
    var floatingWindow: NSWindow?
    var mainWindow: NSWindow?

    func showFloating() {
        if floatingWindow != nil { return }

        objectWillChange.send()
        
        // Mengambil layout mode untuk menentukan ukuran awal
        let layoutMode = FloatingLayoutMode.from(id: UserDefaults.standard.string(forKey: AppConstants.FloatingLayoutSettings.selectedLayoutKey)
            ?? AppConstants.FloatingLayoutSettings.defaultLayoutID)
        let contentSize = layoutMode.contentSize
        
        // Inisialisasi View
        let contentView = FloatingTimerView()

        // Setup NSPanel
        let window = NSPanel(
            contentRect: NSRect(x: 100, y: 600, width: contentSize.width, height: contentSize.height),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView], // Added fullSizeContentView
            backing: .buffered,
            defer: false
        )

        // Konfigurasi Transparansi & Glass
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false // PENTING: Set false agar shadow diatur oleh SwiftUI (rounded), bukan kotak window
        
        // Konfigurasi Level & Behavior
        window.level = .floating
        window.hidesOnDeactivate = false
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        // Hosting View
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
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        NSApp.activate(ignoringOtherApps: true)
        
        if mainWindow == nil {
            mainWindow = makeMainWindow()
        }
        guard let window = mainWindow else { return }

        window.level = .normal
        window.deminiaturize(nil)
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)

        // Ensure visible & focused
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
        }
    }

    private func makeMainWindow() -> NSWindow {
        let fixedSize = NSSize(width: 520, height: 420)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: fixedSize.width, height: fixedSize.height),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor(calibratedRed: 36 / 255, green: 36 / 255, blue: 36 / 255, alpha: 1)
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.identifier = NSUserInterfaceItemIdentifier("DzennMainWindow")
        window.minSize = fixedSize
        window.maxSize = fixedSize
        window.center()
        window.contentView = NSHostingView(rootView: MainView())

        window.standardWindowButton(.miniaturizeButton)?.isEnabled = false
        window.standardWindowButton(.zoomButton)?.isEnabled = false
        DispatchQueue.main.async { [weak window] in
            guard let window else { return }
            self.applyMainWindowTrafficLightsOffset(window)
        }

        return window
    }

    private func applyMainWindowTrafficLightsOffset(_ window: NSWindow) {
        guard let closeButton = window.standardWindowButton(.closeButton),
              let miniButton = window.standardWindowButton(.miniaturizeButton),
              let zoomButton = window.standardWindowButton(.zoomButton) else { return }

        closeButton.frame.origin.x += MainWindowChrome.trafficLightsHorizontalOffset
        miniButton.frame.origin.x += MainWindowChrome.trafficLightsHorizontalOffset
        zoomButton.frame.origin.x += MainWindowChrome.trafficLightsHorizontalOffset

        closeButton.frame.origin.y += MainWindowChrome.trafficLightsVerticalOffset
        miniButton.frame.origin.y += MainWindowChrome.trafficLightsVerticalOffset
        zoomButton.frame.origin.y += MainWindowChrome.trafficLightsVerticalOffset
    }

    func updateFloatingSize(mode: FloatingLayoutMode) {
        guard let window = floatingWindow else { return }
        let size = mode.contentSize
        
        // Animasi resize window agar halus
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().setContentSize(size)
        }
    }
}
