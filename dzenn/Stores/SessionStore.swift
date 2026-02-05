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
}
