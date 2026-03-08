import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @State private var minutes: Int = 25

    // Presets
    @AppStorage("quickPreset1") private var quickPreset1: Int = AppConstants.QuickPresets.defaultValues[0]
    @AppStorage("quickPreset2") private var quickPreset2: Int = AppConstants.QuickPresets.defaultValues[1]
    @AppStorage("quickPreset3") private var quickPreset3: Int = AppConstants.QuickPresets.defaultValues[2]
    @AppStorage(AppConstants.MenuBarSettings.selectedPresetMinutesKey)
    private var selectedPresetMinutes: Int = AppConstants.MenuBarSettings.defaultPresetMinutes

    private let minTime = 1
    private let maxTime = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. RULER SLIDER SECTION (Top)

            RulerPicker(value: self.$minutes, range: self.minTime...self.maxTime)
                .frame(height: 30)
                .padding(.top, 12)
                .padding(.horizontal, 10)

            Spacer()

            // ROW 2: PRESETS
            HStack(spacing: 8) {
                if self.session.isActive {
                    Button("cancel") {
                        self.cancelSession()
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .buttonStyle(.plain)

                    Button("restart") {
                        self.restartSession()
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .buttonStyle(.plain)
                } else {
                    ForEach(
                        Array([self.quickPreset1, self.quickPreset2, self.quickPreset3].enumerated()),
                        id: \.offset)
                    { _, preset in
                        Button(action: {
                            self.minutes = preset
                            self.selectedPresetMinutes = preset
                        }, label: {
                            Text("\(preset)m")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(self.minutes == preset ? .white : .gray)
                                .frame(minWidth: 30) // Area tap lebih nyaman
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            // 3. START & MENU (Bottom) - justify-between dengan FORCE full width
            HStack {
                Button(action: self.handlePrimaryAction) {
                    Text(self.primaryButtonTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Menu(content: {
                    Button("Settings") {
                        MenuBarController.shared?.openSettingsWindow()
                        if MenuBarController.shared == nil {
                            WindowManager.shared.showMainWindow()
                        }
                    }
                    Button("Contact Us") { self.openContact() }
                    Divider()
                    Button("Quit") { NSApp.terminate(nil) }
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                })
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
            .frame(maxWidth: .infinity) // PAKSA full width
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(
            width: AppConstants.MenuBarSettings.panelWidth,
            height: AppConstants.MenuBarSettings.panelHeight
        )
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(18)
        .onAppear {
            self.minutes = min(self.maxTime, max(self.minTime, self.selectedPresetMinutes))
        }
    }

    // MARK: - Actions

    private func startSession() {
        self.session.start(task: "Focus Session", duration: TimeInterval(self.minutes * 60))
        WindowManager.shared.showFloating()
    }

    private func openContact() {
        if let url = URL(string: "mailto:support@dzenn.app") {
            NSWorkspace.shared.open(url)
        }
    }

    private var primaryButtonTitle: String {
        if !self.session.isActive { return "start" }
        return self.session.isPaused ? "resume" : "pause"
    }

    private func handlePrimaryAction() {
        if !self.session.isActive {
            self.startSession()
            return
        }

        if self.session.isPaused {
            self.session.resume()
        } else {
            self.session.pause()
        }
    }

    private func cancelSession() {
        self.session.stop()
        WindowManager.shared.hideFloating()
    }

    private func restartSession() {
        self.startSession()
    }
}

// MARK: - Custom Ruler Component

struct RulerPicker: View {
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        GeometryReader { geo in
            let totalRange = CGFloat(range.upperBound - self.range.lowerBound)
            let stepWidth = geo.size.width / totalRange

            ZStack(alignment: .leading) {
                // Garis-garis Tick (Background)
                HStack(spacing: 0) {
                    ForEach(0...Int(totalRange), id: \.self) { index in
                        Rectangle()
                            .fill(Color.gray.opacity(index % 5 == 0 ? 0.5 : 0.2))
                            .frame(width: 1, height: index % 5 == 0 ? 20 : 10)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Cursor Indicator (Garis Putih Terang)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 28)
                    .shadow(color: .white.opacity(0.5), radius: 2)
                    .offset(x: CGFloat(self.value - self.range.lowerBound) * stepWidth)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let locationX = drag.location.x
                        let percent = max(0, min(1, locationX / geo.size.width))
                        let newValue = Int(Double(range.lowerBound) + (percent * Double(totalRange)))
                        self.value = newValue
                    })
        }
    }
}
