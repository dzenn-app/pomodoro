import Foundation

enum SessionState: Equatable {
    case idle
    case focusing
    case breaking(BreakType)
}

enum BreakType: String, Equatable {
    case short
    case long
}
