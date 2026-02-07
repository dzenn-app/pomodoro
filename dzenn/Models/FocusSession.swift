import Foundation

struct FocusSession: Identifiable, Equatable {
    let id: UUID
    var task: String
    var type: SessionType
    var startTime: Date
    var endTime: Date?

    init(
        id: UUID = UUID(),
        task: String,
        type: SessionType,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.task = task
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
    }
}
