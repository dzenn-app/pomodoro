import Foundation

struct FocusHistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: SessionType
    let startTime: Date
    let endTime: Date
    let duration: Int
    let status: SessionStatus

    init(record: SessionRecord) {
        self.id = record.id
        self.type = record.type
        self.startTime = record.startTime
        self.endTime = record.endTime
        self.duration = record.duration
        self.status = record.status
    }
}

struct DayFocusHistory: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var items: [FocusHistoryItem]

    init(id: UUID = UUID(), date: Date, items: [FocusHistoryItem] = []) {
        self.id = id
        self.date = date
        self.items = items
    }

    init(log: DaySessionLog) {
        self.id = log.id
        self.date = log.date
        self.items = log.sessions
            .sorted { $0.startTime < $1.startTime }
            .map(FocusHistoryItem.init)
    }
}
