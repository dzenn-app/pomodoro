
import Foundation
import Combine

@MainActor
final class TimerService: ObservableObject {

    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning: Bool = false

    private var timer: DispatchSourceTimer?
    private var endTime: Date?
    private var isPaused = false

    func start(duration: TimeInterval) {
        stop()

        remainingTime = duration
        endTime = Date().addingTimeInterval(duration)
        isRunning = true
        isPaused = false

        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: 1)

        timer.setEventHandler { [weak self] in
            guard let self else { return }

            let now = Date()
            let remaining = self.endTime?.timeIntervalSince(now) ?? 0

            if remaining <= 0 {
                self.stop()
            } else {
                self.remainingTime = remaining
            }
        }

        self.timer = timer
        timer.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        endTime = nil
        isRunning = false
        isPaused = false
        remainingTime = 0
    }

    func pause() {
        guard isRunning, let endTime else { return }

        let now = Date()
        remainingTime = max(0, endTime.timeIntervalSince(now))
        timer?.cancel()
        timer = nil
        self.endTime = nil
        isRunning = false
        isPaused = true
    }

    func resume() {
        guard isPaused, remainingTime > 0 else { return }
        start(duration: remainingTime)
    }
}
