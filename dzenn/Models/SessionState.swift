import Foundation

enum SessionState: Equatable {
    case idle
    case focusing
    case breaking(BreakType)
}

enum BreakType: String, Equatable {
    case short
    case long

    var title: String {
        switch self {
        case .short: "Short Break"
        case .long: "Long Break"
        }
    }
}
