import Foundation

struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    var task: String
    var type: SessionType
    var startTime: Date
    var endTime: Date?
    var status: SessionStatus

    init(
        id: UUID = UUID(),
        task: String,
        type: SessionType,
        startTime: Date = Date(),
        endTime: Date? = nil,
        status: SessionStatus = .interrupted
    ) {
        self.id = id
        self.task = task
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
    }
}
