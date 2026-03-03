import Foundation
import Combine

@MainActor
final class TimerService: ObservableObject {

    @Published var remainingTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published private(set) var isPaused: Bool = false

    private var timer: DispatchSourceTimer?
    private var endTime: Date?

    private func cancelTimer() {
        timer?.cancel()
        timer = nil
    }

    func start(duration: TimeInterval) {
        cancelTimer()

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
        cancelTimer()
        endTime = nil
        isRunning = false
        isPaused = false
        remainingTime = 0
    }

    func pause() {
        guard isRunning, let endTime else { return }

        let now = Date()
        remainingTime = max(0, endTime.timeIntervalSince(now))
        cancelTimer()
        self.endTime = nil
        isRunning = false
        isPaused = true
    }

    func resume() {
        guard isPaused, remainingTime > 0 else { return }
        start(duration: remainingTime)
    }
}
