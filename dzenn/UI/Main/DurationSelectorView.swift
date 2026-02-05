// UI/Main/DurationSelectorView.swift

import SwiftUI

struct DurationSelectorView: View {
    @Binding var sessionType: SessionType

    let startLabel: String
    let focusDefaultMinutes: Int
    let breakDefaultMinutes: Int
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
        sessionType: Binding<SessionType>,
        startLabel: String,
        focusDefaultMinutes: Int,
        breakDefaultMinutes: Int,
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
        _sessionType = sessionType
        self.startLabel = startLabel
        self.focusDefaultMinutes = focusDefaultMinutes
        self.breakDefaultMinutes = breakDefaultMinutes
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
        _minutes = State(initialValue: sessionType.wrappedValue == .focus ? focusDefaultMinutes : breakDefaultMinutes)
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Session Type")
                    .font(.title2)
                    .fontWeight(.semibold)

                Picker("", selection: $sessionType) {
                    ForEach(SessionType.allCases) { type in
                        Text(type.title).tag(type)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

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
        .onChange(of: sessionType) { newValue in
            minutes = newValue == .focus ? focusDefaultMinutes : breakDefaultMinutes
        }
    }
}

struct DurationSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DurationSelectorView(
            sessionType: .constant(.focus),
            startLabel: "Start Focus",
            focusDefaultMinutes: 25,
            breakDefaultMinutes: 5,
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
