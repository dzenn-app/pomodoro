import Foundation
import Combine

@MainActor
final class FocusSessionManager: ObservableObject {

    static let shared = FocusSessionManager()

    @Published var activeTask: String = ""
    @Published var duration: TimeInterval = 0
    @Published var isActive: Bool = false

    let timerService = TimerService()

    func start(task: String, duration: TimeInterval) {
        self.activeTask = task
        self.duration = duration
        self.isActive = true

        timerService.start(duration: duration)
    }

    func stop() {
        timerService.stop()
        isActive = false
        activeTask = ""
        duration = 0
    }
}
