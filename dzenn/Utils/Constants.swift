import Foundation

struct SoundOption: Identifiable, Hashable {
    let id: String
    let title: String
    let fileName: String
    let fileExtension: String
}

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

    enum SoundSettings {
        static let selectedSoundKey = "selectedSoundID"
        static let autoMuteAfter5SecondsKey = "autoMuteAfter5Seconds"

        static let defaultSoundID = "alarm-1"
        static let options: [SoundOption] = [
            SoundOption(id: "alarm-1", title: "Alarm 1", fileName: "alarm-1", fileExtension: "m4a"),
            SoundOption(id: "alarm-2", title: "Alarm 2", fileName: "alarm-2", fileExtension: "m4a"),
            SoundOption(id: "alarm-3", title: "Alarm 3", fileName: "alarm-3", fileExtension: "m4a")
        ]
    }

    enum BreakDuration {
        static let shortMinutes = 5
        static let longMinutes = 15
    }
}
