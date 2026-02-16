import SwiftUI

enum FloatingTheme: String, CaseIterable, Identifiable {
    case black
    case glassy
    case cream

    var id: String { rawValue }

    var title: String {
        switch self {
        case .black:
            return "Black"
        case .glassy:
            return "Glassy"
        case .cream:
            return "Cream"
        }
    }

    // MARK: - Solid Background (Non-Glass)

    var backgroundColor: Color {
        switch self {
        case .black:
            return Color.black.opacity(0.85)
        case .cream:
            return Color(red: 0.95, green: 0.90, blue: 0.82)
        case .glassy:
            return .clear // Glass does not use solid background
        }
    }

    // MARK: - Text Colors

    var textColor: Color {
        switch self {
        case .black:
            return .white
        case .glassy, .cream:
            return .primary
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .black:
            return Color.white.opacity(0.8)
        case .glassy, .cream:
            return .secondary
        }
    }

    // MARK: - Border

    var borderColor: Color {
        switch self {
        case .black:
            return Color.white.opacity(0.08)
        case .cream:
            return Color.black.opacity(0.1)
        case .glassy:
            return .clear // Glass does not need fake border
        }
    }

    // MARK: - Glass Configuration

    var isGlass: Bool {
        self == .glassy
    }

    // Keep compatibility with existing view usage.
    var usesGlassyBackground: Bool {
        isGlass
    }

    /// Optional tint for glass
    var glassTint: Color? {
        switch self {
        case .glassy:
            return Color.white.opacity(0.08)
        default:
            return nil
        }
    }

    // MARK: - Backward Compatibility

    static func from(id: String) -> FloatingTheme {
        if id == "white" { return .glassy }
        return FloatingTheme(rawValue: id) ?? .black
    }
}
