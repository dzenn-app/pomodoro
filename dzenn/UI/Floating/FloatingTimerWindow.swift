import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @ObservedObject private var timer = FocusSessionManager.shared.timerService
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey) private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID

    var body: some View {
        let theme = FloatingTheme.from(id: selectedThemeID)
        let clampedOpacity = min(AppConstants.FloatingThemeSettings.maxOpacity,
                                 max(AppConstants.FloatingThemeSettings.minOpacity, floatingOpacity))
        let layoutMode = FloatingLayoutMode.from(id: layoutModeID)

        Group {
            switch layoutMode {
            case .timerOnly:
                timerContent(theme: theme)
                    .frame(height: AppConstants.FloatingLayoutSettings.timerOnlyHeight)
            case .imageOnly:
                imageContent(theme: theme)
                    .frame(height: AppConstants.FloatingLayoutSettings.imageOnlyHeight)
            case .mixed:
                VStack(spacing: 0) {
                    imageContent(theme: theme)
                        .frame(height: AppConstants.FloatingLayoutSettings.mixedImageHeight)
                    timerContent(theme: theme)
                        .frame(height: AppConstants.FloatingLayoutSettings.mixedTimerHeight)
                }
            }
        }
        .frame(width: AppConstants.FloatingLayoutSettings.width)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(theme.backgroundColor.opacity(clampedOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
        .onAppear {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
        .onChange(of: layoutModeID) {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
    }

    private func timerContent(theme: FloatingTheme) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(titleText)
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)

                Text(format(timer.remainingTime))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textColor)
            }

            Spacer()

            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
        }
        .padding(14)
    }

    private func imageContent(theme: FloatingTheme) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.borderColor)
                .opacity(0.2)
            Text("Image")
                .font(.caption)
                .foregroundColor(theme.secondaryTextColor)
        }
        .padding(10)
    }

    private var titleText: String {
        if !session.activeTask.isEmpty {
            return session.activeTask
        }

        switch session.state {
        case .idle:
            return "Idle"
        case .focusing:
            return "Focus Session"
        case .breaking(let type):
            return type.title
        }
    }

    private var statusColor: Color {
        switch session.state {
        case .idle:
            return .gray
        case .focusing:
            return timer.isRunning ? .green : .orange
        case .breaking:
            return timer.isRunning ? .blue : .orange
        }
    }

    private func format(_ time: TimeInterval) -> String {
        let total = Int(time)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
