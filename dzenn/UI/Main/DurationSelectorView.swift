// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    @State private var minutes: Int = AppConstants.FocusDuration.defaultMinutes

    let onStart: (Int) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void
    let onRestart: (Int) -> Void
    let isActive: Bool
    let isPaused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("Focus Duration")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(minutes) min")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()

            Slider(value: Binding(
                get: { Double(minutes) },
                set: { minutes = Int($0.rounded()) }
            ), in: Double(AppConstants.FocusDuration.minMinutes)...Double(AppConstants.FocusDuration.maxMinutes), step: Double(AppConstants.FocusDuration.stepMinutes))
            .frame(width: 300)

            HStack(spacing: 16) {
                Button("-") {
                    minutes = max(
                        AppConstants.FocusDuration.minMinutes,
                        minutes - AppConstants.FocusDuration.stepMinutes
                    )
                }
                .buttonStyle(.bordered)

                Button("+") {
                    minutes = min(
                        AppConstants.FocusDuration.maxMinutes,
                        minutes + AppConstants.FocusDuration.stepMinutes
                    )
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button(isActive ? (isPaused ? "Resume" : "Pause") : "Start Focus") {
                    if isActive {
                        if isPaused {
                            onResume()
                        } else {
                            onPause()
                        }
                    } else {
                        onStart(minutes)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Stop") {
                    onStop()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .frame(maxWidth: .infinity)
                .disabled(!isActive)

                Button("Restart") {
                    onRestart(minutes)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .frame(maxWidth: .infinity)
                .disabled(!isActive)
            }
            .controlSize(.large)
            .frame(width: 420)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(40)
    }
}

struct DurationSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DurationSelectorView(
            onStart: { _ in },
            onPause: {},
            onResume: {},
            onStop: {},
            onRestart: { _ in },
            isActive: false,
            isPaused: false
        )
    }
}
