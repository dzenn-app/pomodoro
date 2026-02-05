// UI/Main/MainView.swift

import SwiftUI

struct MainView: View {
    @ObservedObject private var session = FocusSessionManager.shared

    var body: some View {
        VStack(spacing: 20) {
            DurationSelectorView(
                onStart: { minutes in
                    FocusSessionManager.shared.start(
                        task: "Focus Session",
                        duration: TimeInterval(minutes * 60)
                    )
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
                    FocusSessionManager.shared.start(
                        task: "Focus Session",
                        duration: TimeInterval(minutes * 60)
                    )
                    WindowManager.shared.showFloating()
                },
                isActive: session.isActive,
                isPaused: session.isPaused
            )
        }
        .padding(.vertical, 24)
        .frame(minWidth: 500, minHeight: 400)
    }
}
