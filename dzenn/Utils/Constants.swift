import Foundation

enum AppConstants {
    enum FocusDuration {
        static let defaultMinutes = 25
        static let minMinutes = 5
        static let maxMinutes = 120
        static let stepMinutes = 5
    }

    enum QuickPresets {
        static let defaultValues = [5, 10, 25]
        static let minMinutes = 1
        static let maxMinutes = 60
    }

    enum BreakDuration {
        static let shortMinutes = 5
        static let longMinutes = 15
    }
}
