
import SwiftUI

struct FloatingTimerView: View {
    @State private var time: String = "25:00"
    @State private var task: String = "Focus Session"

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(task)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(time)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
        }
        .padding(14)
        .frame(width: 260, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.85))
        )
    }
}
