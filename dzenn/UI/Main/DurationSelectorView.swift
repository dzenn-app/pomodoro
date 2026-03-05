// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    @AppStorage(AppConstants.QuickPresets.preset1Key)
    private var quickPreset1: Int = AppConstants.QuickPresets.defaultValues[0]
    @AppStorage(AppConstants.QuickPresets.preset2Key)
    private var quickPreset2: Int = AppConstants.QuickPresets.defaultValues[1]
    @AppStorage(AppConstants.QuickPresets.preset3Key)
    private var quickPreset3: Int = AppConstants.QuickPresets.defaultValues[2]
    @AppStorage(AppConstants.SoundSettings.selectedSoundKey)
    private var selectedSoundID: String = AppConstants.SoundSettings.defaultSoundID
    @AppStorage(AppConstants.SoundSettings.autoMuteAfter5SecondsKey)
    private var autoMuteAfter5Seconds: Bool = false
    @AppStorage(AppConstants.SoundSettings.volumeKey)
    private var soundVolume: Double = AppConstants.SoundSettings.defaultVolume
    @AppStorage(AppConstants.MenuBarSettings.compactIconKey)
    private var compactMenuBarIcon: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("General")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                Text("Quick Presets (minutes)")
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack {
                    Spacer()
                    HStack(spacing: 12) {
                        self.presetField(value: self.$quickPreset1)
                        self.presetField(value: self.$quickPreset2)
                        self.presetField(value: self.$quickPreset3)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Completion Sound")
                    Spacer()
                    Picker("", selection: self.$selectedSoundID) {
                        ForEach(AppConstants.SoundSettings.options) { option in
                            Text(option.title).tag(option.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200, alignment: .trailing)
                }
                .padding(.bottom, 12)

                HStack {
                    Text("Volume")
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.1")
                            .foregroundColor(.secondary)
                        CustomSlider(
                            value: self.$soundVolume,
                            range: AppConstants.SoundSettings.minVolume...AppConstants.SoundSettings.maxVolume,
                            step: 0.05)
                            .frame(width: 180)
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 12)

                HStack {
                    Text("Automatically mute after 5 seconds")
                    Spacer()
                    Toggle("", isOn: self.$autoMuteAfter5Seconds)
                        .toggleStyle(.switch)
                }

                HStack {
                    Text("Compact icon on menu bar")
                    Spacer()
                    Toggle("", isOn: self.$compactMenuBarIcon)
                        .toggleStyle(.switch)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .onAppear {
            if !AppConstants.SoundSettings.options.contains(where: { $0.id == selectedSoundID }) {
                self.selectedSoundID = AppConstants.SoundSettings.defaultSoundID
            }
            self.soundVolume = self.clampVolume(self.soundVolume)
        }
        .onChange(of: self.quickPreset1) {
            self.quickPreset1 = self.clampPreset(self.quickPreset1)
        }
        .onChange(of: self.quickPreset2) {
            self.quickPreset2 = self.clampPreset(self.quickPreset2)
        }
        .onChange(of: self.quickPreset3) {
            self.quickPreset3 = self.clampPreset(self.quickPreset3)
        }
        .onChange(of: self.soundVolume) {
            self.soundVolume = self.clampVolume(self.soundVolume)
        }
    }

    private func presetField(value: Binding<Int>) -> some View {
        TextField("", value: value, formatter: Self.presetFormatter)
            .textFieldStyle(.roundedBorder)
            .frame(width: 64)
            .multilineTextAlignment(.center)
    }

    private func clampPreset(_ value: Int) -> Int {
        min(AppConstants.QuickPresets.maxMinutes, max(AppConstants.QuickPresets.minMinutes, value))
    }

    private func clampVolume(_ value: Double) -> Double {
        min(AppConstants.SoundSettings.maxVolume, max(AppConstants.SoundSettings.minVolume, value))
    }

    private static let presetFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}

struct DurationSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DurationSelectorView()
    }
}
