import Foundation
import Combine

@MainActor
final class FocusSessionManager: ObservableObject {

    static let shared = FocusSessionManager()

    @Published var activeTask: String = ""
    @Published var duration: TimeInterval = 0
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var state: SessionState = .idle

    let timerService = TimerService()

    private var cancellables = Set<AnyCancellable>()
    private var completionHandled = false

    private init() {
        timerService.$remainingTime
            .combineLatest(timerService.$isRunning, timerService.$isPaused)
            .sink { [weak self] remainingTime, isRunning, timerIsPaused in
                guard let self else { return }

                if self.state != .idle,
                   !self.completionHandled,
                   !isRunning,
                   !timerIsPaused,
                   remainingTime <= 0 {
                    self.handleTimerFinished()
                }
            }
            .store(in: &cancellables)
    }

    func start(task: String, duration: TimeInterval) {
        self.activeTask = task
        self.duration = duration
        self.isActive = true
        self.isPaused = false
        self.state = .focusing
        self.completionHandled = false

        timerService.start(duration: duration)
    }

    func stop() {
        timerService.stop()
        completionHandled = true
        resetSession()
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

    func startBreak(type: BreakType, minutes: Int? = nil) {
        let minutes = minutes ?? (type == .short
            ? AppConstants.BreakDuration.shortMinutes
            : AppConstants.BreakDuration.longMinutes)

        activeTask = type.title
        duration = TimeInterval(minutes * 60)
        isActive = true
        isPaused = false
        state = .breaking(type)
        completionHandled = false

        timerService.start(duration: duration)
    }

    private func handleTimerFinished() {
        completionHandled = true
        switch state {
        case .focusing:
            prepareBreak(type: .short)
            WindowManager.shared.hideFloating()
            WindowManager.shared.showMainWindow()
        case .breaking:
            resetSession()
            WindowManager.shared.hideFloating()
            WindowManager.shared.showMainWindow()
        case .idle:
            break
        }
    }

    private func resetSession() {
        isActive = false
        isPaused = false
        activeTask = ""
        duration = 0
        state = .idle
        completionHandled = true
    }

    private func prepareBreak(type: BreakType) {
        activeTask = ""
        duration = TimeInterval(
            (type == .short
                ? AppConstants.BreakDuration.shortMinutes
                : AppConstants.BreakDuration.longMinutes
            ) * 60
        )
        isActive = false
        isPaused = false
        state = .breaking(type)
    }
}
