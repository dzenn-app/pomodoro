import Cocoa
import Combine
import SwiftUI

final class MenuBarController: NSObject {
    static var shared: MenuBarController?

    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let session = FocusSessionManager.shared
    private var cancellables = Set<AnyCancellable>()

    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()

        super.init()

        if let button = statusItem.button {
            button.action = #selector(self.togglePopover(_:))
            button.target = self
        }

        self.popover.contentSize = NSSize(
            width: AppConstants.MenuBarSettings.panelWidth,
            height: AppConstants.MenuBarSettings.panelHeight
        )
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: MenuBarView())

        MenuBarController.shared = self

        self.bindStatusUpdates()
        self.updateStatusItem()
    }

    @objc private func togglePopover(_ sender: Any?) {
        if self.popover.isShown {
            self.popover.performClose(sender)
        } else {
            self.showPopover()
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    func openSettingsWindow() {
        self.popover.performClose(nil)
        DispatchQueue.main.async {
            WindowManager.shared.showMainWindow()
        }
    }

    private func bindStatusUpdates() {
        self.session.timerService.$remainingTime
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &self.cancellables)

        self.session.timerService.$isRunning
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &self.cancellables)

        self.session.timerService.$isPaused
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in self?.updateStatusItem() }
            .store(in: &self.cancellables)
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }

        let defaults = UserDefaults.standard
        let compact = defaults.object(forKey: AppConstants.MenuBarSettings.compactIconKey) as? Bool
            ?? true

        if compact {
            button.title = ""
            if let image = NSImage(named: "MenuBarIcon") {
                button.image = self.makeRoundedStatusImage(from: image)
                button.image?.isTemplate = false
            } else {
                button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Dzenn")
            }
            self.statusItem.length = NSStatusItem.variableLength
            self.clearStatusWrapper(on: button)
        } else {
            button.image = nil
            button.title = self.currentMenuBarTitle()
            self.applyStatusWrapper(on: button)
            let targetWidth = max(28, button.intrinsicContentSize.width + 4)
            self.statusItem.length = targetWidth
        }
    }

    private func currentMenuBarTitle() -> String {
        let remaining = self.session.timerService.remainingTime
        let isActive = self.session.timerService.isRunning || self.session.timerService.isPaused
        if isActive && remaining > 0 {
            return self.formatTime(remaining)
        }

        let defaults = UserDefaults.standard
        let presetMinutes = defaults.object(
            forKey: AppConstants.MenuBarSettings.selectedPresetMinutesKey) as? Int
            ?? AppConstants.MenuBarSettings.defaultPresetMinutes
        return String(format: "%d:00", max(0, presetMinutes))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(time.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func applyStatusWrapper(on button: NSStatusBarButton) {
        button.wantsLayer = true
        button.layer?.cornerRadius = 4
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        button.layer?.backgroundColor = NSColor.clear.cgColor
    }

    private func clearStatusWrapper(on button: NSStatusBarButton) {
        button.layer?.borderWidth = 0
        button.layer?.borderColor = nil
        button.layer?.backgroundColor = nil
        button.wantsLayer = false
    }

    private func makeRoundedStatusImage(from image: NSImage) -> NSImage {
        let targetSize = NSSize(width: 12, height: 12)
        let cornerRadius: CGFloat = 4
        let finalImage = NSImage(size: targetSize)
        finalImage.lockFocus()

        let rect = NSRect(origin: .zero, size: targetSize)
        let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        path.addClip()

        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
        finalImage.unlockFocus()
        finalImage.isTemplate = false
        return finalImage
    }
}
