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
    let sessionStore = SessionStore.shared

    private var cancellables = Set<AnyCancellable>()
    private var completionHandled = false
    private var currentSessionStart: Date?
    private var currentSessionType: SessionType?
    private var currentSessionPlannedDuration: TimeInterval?

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
        self.currentSessionStart = Date()
        self.currentSessionType = .focus
        self.currentSessionPlannedDuration = duration

        timerService.start(duration: duration)
    }

    func stop() {
        if isActive {
            recordCurrentSession(status: .stopped)
        }
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
        currentSessionStart = Date()
        currentSessionType = .break
        currentSessionPlannedDuration = duration

        timerService.start(duration: duration)
    }

    private func handleTimerFinished() {
        completionHandled = true
        switch state {
        case .focusing:
            recordCurrentSession(status: .completed)
            prepareBreak(type: .short)
            WindowManager.shared.hideFloating()
            WindowManager.shared.showMainWindow()
        case .breaking:
            recordCurrentSession(status: .completed)
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
        clearCurrentSession()
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

    private func recordCurrentSession(status: SessionStatus) {
        guard let start = currentSessionStart, let type = currentSessionType else { return }

        let end = Date()
        let planned = currentSessionPlannedDuration ?? end.timeIntervalSince(start)
        let elapsed: TimeInterval

        switch status {
        case .completed:
            elapsed = planned
        case .stopped, .interrupted:
            elapsed = max(0, planned - timerService.remainingTime)
        }

        let record = SessionRecord(
            type: type,
            startTime: start,
            endTime: end,
            duration: Int(elapsed.rounded()),
            status: status
        )
        sessionStore.add(record)
        clearCurrentSession()
    }

    private func clearCurrentSession() {
        currentSessionStart = nil
        currentSessionType = nil
        currentSessionPlannedDuration = nil
    }
}
