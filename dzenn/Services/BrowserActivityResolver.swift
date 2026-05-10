import Foundation
import AppKit

final class BrowserActivityResolver {
    static let shared = BrowserActivityResolver()

    private init() {}

    func resolve(for app: NSRunningApplication) -> WebsiteVisitRecord? {
        guard let bundleID = app.bundleIdentifier,
              AppConstants.AnalyticsSettings.supportedBrowsers[bundleID] != nil else {
            return nil
        }

        return nil
    }
}
