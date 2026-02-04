import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Dzenn Main App")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 12) {
                Button("Start Focus") {
                    FocusSessionManager.shared.start(
                        task: "Deep Work",
                        duration: 25 * 60
                    )
                    WindowManager.shared.showFloating()
                }

                Button("Stop Focus") {
                    FocusSessionManager.shared.stop()
                    WindowManager.shared.hideFloating()
                }
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    MainView()
}
