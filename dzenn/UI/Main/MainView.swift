import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Dzenn Main App")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 12) {
                Button("Start Focus") {
                    WindowManager.shared.showFloating()
                }

                Button("Stop Focus") {
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
