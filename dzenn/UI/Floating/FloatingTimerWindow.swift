import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @ObservedObject private var timer = FocusSessionManager.shared.timerService

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(session.activeTask.isEmpty ? "Focus Session" : session.activeTask)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(format(timer.remainingTime))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            Circle()
                .fill(timer.isRunning ? Color.green : Color.red)
                .frame(width: 10, height: 10)
        }
        .padding(14)
        .frame(width: 260, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.85))
        )
    }

    private func format(_ time: TimeInterval) -> String {
        let total = Int(time)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
