import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published private(set) var logs: [DaySessionLog] = []

    func add(_ record: SessionRecord) {
        let day = Calendar.current.startOfDay(for: record.startTime)

        if let index = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            logs[index].sessions.append(record)
        } else {
            let log = DaySessionLog(date: day, sessions: [record])
            logs.append(log)
        }
    }

    func history() -> [DayFocusHistory] {
        logs
            .sorted { $0.date > $1.date }
            .map(DayFocusHistory.init)
    }

    func dailyStats() -> [DailyStats] {
        logs
            .sorted { $0.date < $1.date }
            .map(StatsEngine.dailyStats(from:))
    }

    func totalStats() -> Stats {
        StatsEngine.totalStats(from: logs)
    }
}
