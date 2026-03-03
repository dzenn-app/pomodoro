import SwiftUI

enum FloatingTheme: String, CaseIterable, Identifiable {
    case black

    var id: String {
        rawValue
    }

    var title: String {
        "Black"
    }

    var backgroundColor: Color {
        .black
    }

    var textColor: Color {
        .white
    }

    var secondaryTextColor: Color {
        Color.white.opacity(0.8)
    }

    var borderColor: Color {
        Color.white.opacity(0.08)
    }
}
