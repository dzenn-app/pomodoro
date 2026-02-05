import Foundation

struct DaySessionLog: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var sessions: [SessionRecord]

    init(id: UUID = UUID(), date: Date, sessions: [SessionRecord] = []) {
        self.id = id
        self.date = date
        self.sessions = sessions
    }
}
