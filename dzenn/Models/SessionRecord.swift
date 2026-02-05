import Foundation

struct SessionRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let type: SessionType
    let startTime: Date
    let endTime: Date
    let duration: Int
    let status: SessionStatus

    init(
        id: UUID = UUID(),
        type: SessionType,
        startTime: Date,
        endTime: Date,
        duration: Int,
        status: SessionStatus
    ) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.status = status
    }
}
