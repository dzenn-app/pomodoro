import Cocoa
import SwiftUI

final class MenuBarController: NSObject {
    static var shared: MenuBarController?

    private let statusItem: NSStatusItem
    private let popover: NSPopover

    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()

        super.init()

        if let button = statusItem.button {
            if let image = NSImage(named: "MenuBarIcon") {
                button.image = self.makeRoundedStatusImage(from: image)
                button.image?.isTemplate = false
            } else {
                button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Dzenn")
            }
            button.action = #selector(self.togglePopover(_:))
            button.target = self
        }

        self.popover.contentSize = NSSize(width: 360, height: 145)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: MenuBarView())

        MenuBarController.shared = self
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
