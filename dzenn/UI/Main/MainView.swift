// UI/Main/MainView.swift

import SwiftUI

struct MainView: View {
    @State private var selection: SidebarItem? = .general

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.systemImage)
                    .tag(item)
            }
            .listStyle(.sidebar)
        } detail: {
            switch selection ?? .general {
            case .general:
                GeneralSettingsView()
            case .floatingApp:
                FloatingAppSettingsView()
            }
        }
        .frame(minWidth: 700, minHeight: 450)
    }
}

private enum SidebarItem: String, CaseIterable, Identifiable {
    case general
    case floatingApp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .floatingApp:
            return "Floating App"
        }
    }

    var systemImage: String {
        switch self {
        case .general:
            return "gearshape"
        case .floatingApp:
            return "rectangle.on.rectangle"
        }
    }
}

private struct GeneralSettingsView: View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: session.state) {
            if case .breaking = session.state {
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

private struct FloatingAppSettingsView: View {
    var body: some View {
        VStack {
            Text("Hello World")
                .font(.title2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
