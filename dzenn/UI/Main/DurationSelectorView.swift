// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    let title: String
    let startLabel: String
    let defaultMinutes: Int
    let minMinutes: Int
    let maxMinutes: Int
    let stepMinutes: Int

    let onStart: (Int) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void
    let onRestart: (Int) -> Void
    let isActive: Bool
    let isPaused: Bool

    @State private var minutes: Int

    init(
        title: String,
        startLabel: String,
        defaultMinutes: Int,
        minMinutes: Int,
        maxMinutes: Int,
        stepMinutes: Int,
        onStart: @escaping (Int) -> Void,
        onPause: @escaping () -> Void,
        onResume: @escaping () -> Void,
        onStop: @escaping () -> Void,
        onRestart: @escaping (Int) -> Void,
        isActive: Bool,
        isPaused: Bool
    ) {
        self.title = title
        self.startLabel = startLabel
        self.defaultMinutes = defaultMinutes
        self.minMinutes = minMinutes
        self.maxMinutes = maxMinutes
        self.stepMinutes = stepMinutes
        self.onStart = onStart
        self.onPause = onPause
        self.onResume = onResume
        self.onStop = onStop
        self.onRestart = onRestart
        self.isActive = isActive
        self.isPaused = isPaused
        _minutes = State(initialValue: defaultMinutes)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(minutes) min")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()

            Slider(value: Binding(
                get: { Double(minutes) },
                set: { minutes = Int($0.rounded()) }
            ), in: Double(minMinutes)...Double(maxMinutes), step: Double(stepMinutes))
            .frame(width: 300)

            HStack(spacing: 16) {
                Button("-") {
                    minutes = max(minMinutes, minutes - stepMinutes)
                }
                .buttonStyle(.bordered)

                Button("+") {
                    minutes = min(maxMinutes, minutes + stepMinutes)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button(isActive ? (isPaused ? "Resume" : "Pause") : startLabel) {
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
        .onChange(of: defaultMinutes) { minutes = defaultMinutes }
    }
}

struct DurationSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DurationSelectorView(
            title: "Focus Duration",
            startLabel: "Start Focus",
            defaultMinutes: 25,
            minMinutes: 5,
            maxMinutes: 120,
            stepMinutes: 5,
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
