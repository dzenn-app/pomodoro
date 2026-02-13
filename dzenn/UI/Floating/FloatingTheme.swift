import SwiftUI

enum FloatingTheme: String, CaseIterable, Identifiable {
    case black
    case white
    case cream

    var id: String { rawValue }

    var title: String {
        switch self {
        case .black:
            return "Black"
        case .white:
            return "White"
        case .cream:
            return "Cream"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .black:
            return Color.black.opacity(0.85)
        case .white:
            return Color.white
        case .cream:
            return Color(red: 0.95, green: 0.90, blue: 0.82)
        }
    }

    var textColor: Color {
        switch self {
        case .black:
            return Color.white
        case .white, .cream:
            return Color.black
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .black:
            return Color.white.opacity(0.8)
        case .white, .cream:
            return Color.black.opacity(0.7)
        }
    }

    var borderColor: Color {
        switch self {
        case .black:
            return Color.white.opacity(0.08)
        case .white, .cream:
            return Color.black.opacity(0.1)
        }
    }

    static func from(id: String) -> FloatingTheme {
        FloatingTheme(rawValue: id) ?? .black
    }
}
