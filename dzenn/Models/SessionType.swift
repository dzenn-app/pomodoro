import Foundation

enum SessionType: String, CaseIterable, Identifiable {
    case focus
    case `break`

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: return "Focus Session"
        case .break: return "Break Session"
        }
    }
}
