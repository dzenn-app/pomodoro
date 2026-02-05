import Foundation

struct Stats: Codable, Equatable {
    var totalFocusSeconds: Int
    var totalBreakSeconds: Int
    var sessionCount: Int

    init(totalFocusSeconds: Int = 0, totalBreakSeconds: Int = 0, sessionCount: Int = 0) {
        self.totalFocusSeconds = totalFocusSeconds
        self.totalBreakSeconds = totalBreakSeconds
        self.sessionCount = sessionCount
    }
}
