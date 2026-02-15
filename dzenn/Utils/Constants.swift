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
        static let preset1Key = "quickPreset1"
        static let preset2Key = "quickPreset2"
        static let preset3Key = "quickPreset3"
        static let defaultValues = [5, 10, 25]
        static let minMinutes = 1
        static let maxMinutes = 60
    }

    enum SoundSettings {
        static let selectedSoundKey = "selectedSoundID"
        static let autoMuteAfter5SecondsKey = "autoMuteAfter5Seconds"
        static let volumeKey = "soundVolume"

        static let defaultSoundID = "alarm-1"
        static let defaultVolume = 0.6
        static let minVolume = 0.0
        static let maxVolume = 1.0
        static let options: [SoundOption] = [
            SoundOption(id: "alarm-1", title: "Alarm 1", fileName: "alarm-1", fileExtension: "m4a"),
            SoundOption(id: "alarm-2", title: "Alarm 2", fileName: "alarm-2", fileExtension: "m4a"),
            SoundOption(id: "alarm-3", title: "Alarm 3", fileName: "alarm-3", fileExtension: "m4a")
        ]
    }

    enum FloatingThemeSettings {
        static let selectedThemeKey = "floatingTheme"
        static let defaultThemeID = "black"
        static let opacityKey = "floatingOpacity"
        static let defaultOpacity = 0.85
        static let minOpacity = 0.4
        static let maxOpacity = 1.0
    }

    enum FloatingLayoutSettings {
        static let selectedLayoutKey = "floatingLayoutMode"
        static let defaultLayoutID = "timerOnly"
        static let imagePathKey = "floatingImagePath"
        static let showTimerOnImageKey = "showTimerOnImage"
        static let width: CGFloat = 260
        static let timerOnlyHeight: CGFloat = 90
        static let imageOnlyHeight: CGFloat = 200
        static let mixedHeight: CGFloat = 240
        static let mixedImageHeight: CGFloat = 150
        static let mixedTimerHeight: CGFloat = 90
    }

    enum BreakDuration {
        static let shortMinutes = 5
        static let longMinutes = 15
    }
}
