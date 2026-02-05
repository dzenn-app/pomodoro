// UI/Main/MainView.swift

import SwiftUI

struct MainView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @State private var selectedSessionType: SessionType = .focus

    var body: some View {
        VStack(spacing: 20) {
            DurationSelectorView(
                sessionType: $selectedSessionType,
                startLabel: startLabel,
                focusDefaultMinutes: AppConstants.FocusDuration.defaultMinutes,
                breakDefaultMinutes: AppConstants.BreakDuration.shortMinutes,
                minMinutes: AppConstants.FocusDuration.minMinutes,
                maxMinutes: AppConstants.FocusDuration.maxMinutes,
                stepMinutes: AppConstants.FocusDuration.stepMinutes,
                onStart: { minutes in
                    switch selectedSessionType {
                    case .focus:
                        FocusSessionManager.shared.start(
                            task: "Focus Session",
                            duration: TimeInterval(minutes * 60)
                        )
                    case .break:
                        FocusSessionManager.shared.startBreak(
                            type: .short,
                            minutes: minutes
                        )
                    }
                    WindowManager.shared.showFloating()
                },
                onPause: {
                    FocusSessionManager.shared.pause()
                },
                onResume: {
                    FocusSessionManager.shared.resume()
                    WindowManager.shared.showFloating()
                },
                onStop: {
                    FocusSessionManager.shared.stop()
                    WindowManager.shared.hideFloating()
                },
                onRestart: { minutes in
                    FocusSessionManager.shared.stop()
                    switch selectedSessionType {
                    case .focus:
                        FocusSessionManager.shared.start(
                            task: "Focus Session",
                            duration: TimeInterval(minutes * 60)
                        )
                    case .break:
                        FocusSessionManager.shared.startBreak(
                            type: .short,
                            minutes: minutes
                        )
                    }
                    WindowManager.shared.showFloating()
                },
                isActive: session.isActive,
                isPaused: session.isPaused
            )
        }
        .padding(.vertical, 24)
        .frame(minWidth: 500, minHeight: 400)
        .onChange(of: session.state) { newState in
            if case .breaking = newState {
                selectedSessionType = .break
            }
        }
    }

    private var startLabel: String {
        switch selectedSessionType {
        case .break:
            return "Start Break"
        case .focus:
            return "Start Focus"
        }
    }
}
