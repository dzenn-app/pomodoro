// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    @AppStorage(AppConstants.QuickPresets.preset1Key) private var quickPreset1: Int = AppConstants.QuickPresets.defaultValues[0]
    @AppStorage(AppConstants.QuickPresets.preset2Key) private var quickPreset2: Int = AppConstants.QuickPresets.defaultValues[1]
    @AppStorage(AppConstants.QuickPresets.preset3Key) private var quickPreset3: Int = AppConstants.QuickPresets.defaultValues[2]
    @AppStorage(AppConstants.SoundSettings.selectedSoundKey) private var selectedSoundID: String = AppConstants.SoundSettings.defaultSoundID
    @AppStorage(AppConstants.SoundSettings.autoMuteAfter5SecondsKey) private var autoMuteAfter5Seconds: Bool = false
    @AppStorage(AppConstants.SoundSettings.volumeKey) private var soundVolume: Double = AppConstants.SoundSettings.defaultVolume

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
                        presetField(value: $quickPreset1)
                        presetField(value: $quickPreset2)
                        presetField(value: $quickPreset3)
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 10) {
                Text("Sound")
                    .font(.title3)
                    .fontWeight(.semibold)

                Picker("Completion Sound", selection: $selectedSoundID) {
                    ForEach(AppConstants.SoundSettings.options) { option in
                        Text(option.title).tag(option.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 240, alignment: .leading)

                HStack(spacing: 12) {
                    Text("Volume")
                        .frame(width: 60, alignment: .leading)

                    Slider(
                        value: $soundVolume,
                        in: AppConstants.SoundSettings.minVolume...AppConstants.SoundSettings.maxVolume,
                        step: 0.05
                    )

                    Text("\(Int((soundVolume * 100).rounded()))%")
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .frame(width: 44, alignment: .trailing)
                }

                Toggle("Automatically mute after 5 seconds", isOn: $autoMuteAfter5Seconds)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .onAppear {
            if !AppConstants.SoundSettings.options.contains(where: { $0.id == selectedSoundID }) {
                selectedSoundID = AppConstants.SoundSettings.defaultSoundID
            }
            soundVolume = clampVolume(soundVolume)
        }
        .onChange(of: quickPreset1) {
            quickPreset1 = clampPreset(quickPreset1)
        }
        .onChange(of: quickPreset2) {
            quickPreset2 = clampPreset(quickPreset2)
        }
        .onChange(of: quickPreset3) {
            quickPreset3 = clampPreset(quickPreset3)
        }
        .onChange(of: soundVolume) {
            soundVolume = clampVolume(soundVolume)
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
