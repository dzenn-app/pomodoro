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

struct DailyStats: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var focusSeconds: Int
    var breakSeconds: Int
    var focusSessions: Int
    var breakSessions: Int

    var totalSessions: Int { focusSessions + breakSessions }

    init(
        id: UUID = UUID(),
        date: Date,
        focusSeconds: Int = 0,
        breakSeconds: Int = 0,
        focusSessions: Int = 0,
        breakSessions: Int = 0
    ) {
        self.id = id
        self.date = date
        self.focusSeconds = focusSeconds
        self.breakSeconds = breakSeconds
        self.focusSessions = focusSessions
        self.breakSessions = breakSessions
    }
}
