// UI/Main/MainView.swift

import SwiftUI

struct MainView: View {
    @ObservedObject private var session = FocusSessionManager.shared

    var body: some View {
        VStack(spacing: 20) {
            DurationSelectorView(
                title: selectorTitle,
                startLabel: startLabel,
                defaultMinutes: defaultMinutes,
                minMinutes: AppConstants.FocusDuration.minMinutes,
                maxMinutes: AppConstants.FocusDuration.maxMinutes,
                stepMinutes: AppConstants.FocusDuration.stepMinutes,
                onStart: { minutes in
                    switch session.state {
                    case .breaking(let type):
                        FocusSessionManager.shared.startBreak(
                            type: type,
                            minutes: minutes
                        )
                    case .idle, .focusing:
                        FocusSessionManager.shared.start(
                            task: "Focus Session",
                            duration: TimeInterval(minutes * 60)
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
                    switch session.state {
                    case .breaking(let type):
                        FocusSessionManager.shared.startBreak(
                            type: type,
                            minutes: minutes
                        )
                    case .idle, .focusing:
                        FocusSessionManager.shared.start(
                            task: "Focus Session",
                            duration: TimeInterval(minutes * 60)
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
    }

    private var selectorTitle: String {
        switch session.state {
        case .breaking(let type):
            return type.title
        case .idle, .focusing:
            return "Focus Duration"
        }
    }

    private var startLabel: String {
        switch session.state {
        case .breaking:
            return "Start Break"
        case .idle, .focusing:
            return "Start Focus"
        }
    }

    private var defaultMinutes: Int {
        switch session.state {
        case .breaking(let type):
            return type == .short
                ? AppConstants.BreakDuration.shortMinutes
                : AppConstants.BreakDuration.longMinutes
        case .idle, .focusing:
            return AppConstants.FocusDuration.defaultMinutes
        }
    }
}
