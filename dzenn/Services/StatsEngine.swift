import Foundation

struct StatsEngine {
    static func dailyStats(from log: DaySessionLog) -> DailyStats {
        var stats = DailyStats(date: log.date)

        for record in log.sessions {
            switch record.type {
            case .focus:
                stats.focusSeconds += record.duration
                stats.focusSessions += 1
            case .break:
                stats.breakSeconds += record.duration
                stats.breakSessions += 1
            }
        }

        return stats
    }

    static func totalStats(from logs: [DaySessionLog]) -> Stats {
        var totalFocus = 0
        var totalBreak = 0
        var totalSessions = 0

        for log in logs {
            for record in log.sessions {
                totalSessions += 1
                switch record.type {
                case .focus:
                    totalFocus += record.duration
                case .break:
                    totalBreak += record.duration
                }
            }
        }

        return Stats(
            totalFocusSeconds: totalFocus,
            totalBreakSeconds: totalBreak,
            sessionCount: totalSessions
        )
    }
}
