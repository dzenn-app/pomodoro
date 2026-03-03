import Foundation

enum SessionType: String, CaseIterable, Identifiable {
    case focus
    case `break`

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .focus: "Focus Session"
        case .break: "Break Session"
        }
    }
}
