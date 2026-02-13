import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @ObservedObject private var timer = FocusSessionManager.shared.timerService
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID

    var body: some View {
        let theme = FloatingTheme.from(id: selectedThemeID)

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
        .frame(width: 260, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(theme.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
        )
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
