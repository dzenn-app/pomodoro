// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    @AppStorage("quickPreset1") private var quickPreset1: Int = AppConstants.QuickPresets.defaultValues[0]
    @AppStorage("quickPreset2") private var quickPreset2: Int = AppConstants.QuickPresets.defaultValues[1]
    @AppStorage("quickPreset3") private var quickPreset3: Int = AppConstants.QuickPresets.defaultValues[2]

    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Presets (minutes)")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                presetField(value: $quickPreset1)
                presetField(value: $quickPreset2)
                presetField(value: $quickPreset3)
            }
        }
        .padding(24)
        .onChange(of: quickPreset1) {
            quickPreset1 = clampPreset(quickPreset1)
        }
        .onChange(of: quickPreset2) {
            quickPreset2 = clampPreset(quickPreset2)
        }
        .onChange(of: quickPreset3) {
            quickPreset3 = clampPreset(quickPreset3)
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
