import Foundation
import Combine

@MainActor
final class FocusSessionManager: ObservableObject {

    static let shared = FocusSessionManager()

    @Published var activeTask: String = ""
    @Published var duration: TimeInterval = 0
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false

    let timerService = TimerService()

    private var cancellables = Set<AnyCancellable>()

    private init() {
        timerService.$remainingTime
            .combineLatest(timerService.$isRunning, timerService.$isPaused)
            .sink { [weak self] remainingTime, isRunning, timerIsPaused in
                guard let self else { return }

                if self.isActive, !isRunning, !timerIsPaused, remainingTime <= 0 {
                    self.isActive = false
                    self.isPaused = false
                    self.activeTask = ""
                    self.duration = 0
                }
            }
            .store(in: &cancellables)
    }

    func start(task: String, duration: TimeInterval) {
        self.activeTask = task
        self.duration = duration
        self.isActive = true
        self.isPaused = false

        timerService.start(duration: duration)
    }

    func stop() {
        timerService.stop()
        isActive = false
        isPaused = false
        activeTask = ""
        duration = 0
    }

    func pause() {
        guard isActive, !isPaused else { return }
        timerService.pause()
        isPaused = true
    }

    func resume() {
        guard isActive, isPaused else { return }
        timerService.resume()
        isPaused = false
    }
}
