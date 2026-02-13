import Foundation
import Combine
import AVFoundation

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
    private let soundAlertPlayer = SoundAlertPlayer()

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
        soundAlertPlayer.stop()
        self.activeTask = task
        self.duration = duration
        self.isActive = true
        self.isPaused = false
        self.state = .focusing
        self.completionHandled = false

        timerService.start(duration: duration)
    }

    func stop() {
        soundAlertPlayer.stop()
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
        soundAlertPlayer.stop()
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
        playCompletionSoundIfNeeded()

        switch state {
        case .focusing:
            prepareBreak(type: .short)
            WindowManager.shared.hideFloating()
            MenuBarController.shared?.showPopover()
        case .breaking:
            resetSession()
            WindowManager.shared.hideFloating()
            MenuBarController.shared?.showPopover()
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

    private func playCompletionSoundIfNeeded() {
        let defaults = UserDefaults.standard
        let selectedSoundID = defaults.string(forKey: AppConstants.SoundSettings.selectedSoundKey)
            ?? AppConstants.SoundSettings.defaultSoundID
        let autoMuteAfter5Seconds = defaults.object(forKey: AppConstants.SoundSettings.autoMuteAfter5SecondsKey) as? Bool
            ?? false

        soundAlertPlayer.play(
            soundID: selectedSoundID,
            autoMuteAfter5Seconds: autoMuteAfter5Seconds
        )
    }
}

private final class SoundAlertPlayer {
    private var player: AVAudioPlayer?
    private var autoMuteWorkItem: DispatchWorkItem?

    func play(soundID: String, autoMuteAfter5Seconds: Bool) {
        stop()

        guard let option = AppConstants.SoundSettings.options.first(where: { $0.id == soundID }) else {
            print("[SoundAlertPlayer] Unknown sound id: \(soundID)")
            return
        }

        let soundURL =
            Bundle.main.url(
                forResource: option.fileName,
                withExtension: option.fileExtension,
                subdirectory: "Sounds"
            ) ??
            Bundle.main.url(
                forResource: option.fileName,
                withExtension: option.fileExtension
            )

        guard let soundURL else {
            print("[SoundAlertPlayer] Sound file not found: \(option.fileName).\(option.fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            self.player = player
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } catch {
            print("[SoundAlertPlayer] Failed to play sound: \(error.localizedDescription)")
            return
        }

        guard autoMuteAfter5Seconds else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.stop()
        }

        autoMuteWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }

    func stop() {
        autoMuteWorkItem?.cancel()
        autoMuteWorkItem = nil
        player?.stop()
        player = nil
    }
}
