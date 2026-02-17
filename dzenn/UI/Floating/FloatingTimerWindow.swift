import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject private var session = FocusSessionManager.shared
    @ObservedObject private var timer = FocusSessionManager.shared.timerService
    
    // Settings
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey) private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID
    @AppStorage(AppConstants.FloatingLayoutSettings.imagePathKey) private var imagePath: String = ""
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetXKey) private var imageOffsetX: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetYKey) private var imageOffsetY: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset

    var body: some View {
        let theme = FloatingTheme.from(id: selectedThemeID)
        let clampedOpacity = min(AppConstants.FloatingThemeSettings.maxOpacity,
                                 max(AppConstants.FloatingThemeSettings.minOpacity, floatingOpacity))
        let layoutMode = FloatingLayoutMode.from(id: layoutModeID)

        Group {
            switch layoutMode {
            case .timerOnly:
                timerContent(theme: theme)
                    .frame(height: AppConstants.FloatingLayoutSettings.timerOnlyHeight)
            case .imageOnly:
                imageContent(theme: theme, imagePath: imagePath)
                    .frame(height: AppConstants.FloatingLayoutSettings.imageOnlyHeight)
            case .mixed:
                VStack(spacing: 0) {
                    imageContent(theme: theme, imagePath: imagePath)
                        .frame(height: AppConstants.FloatingLayoutSettings.mixedImageHeight)
                    timerContent(theme: theme)
                        .frame(height: AppConstants.FloatingLayoutSettings.mixedTimerHeight)
                }
            }
        }
        .frame(width: AppConstants.FloatingLayoutSettings.width)
        .background(panelBackground(theme: theme, opacity: clampedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .animation(.easeInOut(duration: 0.28), value: selectedThemeID)
        .animation(.easeInOut(duration: 0.2), value: floatingOpacity)
        .onAppear {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
        .onChange(of: layoutModeID) {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
    }

    private func timerContent(theme: FloatingTheme) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(titleText)
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)

                Text(format(timer.remainingTime))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textColor)
            }

            Spacer()

            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
        }
        .padding(14)
    }

    private func imageContent(theme: FloatingTheme, imagePath: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.borderColor)
                .opacity(0.2)

            if let image = loadImage(path: imagePath) {
                GeometryReader { proxy in
                    let containerSize = proxy.size
                    let normalizedOffset = FloatingImageFraming.clampedNormalizedOffset(x: imageOffsetX, y: imageOffsetY)
                    let imageOffset = FloatingImageFraming.offset(fromNormalized: normalizedOffset,
                                                                  imageSize: image.size,
                                                                  containerSize: containerSize)

                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: containerSize.width, height: containerSize.height)
                        .offset(x: imageOffset.width, y: imageOffset.height)
                        .frame(width: containerSize.width, height: containerSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Text("Image")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(10)
    }

    @ViewBuilder
    private func panelBackground(theme: FloatingTheme, opacity: Double) -> some View {
        let panelShape = RoundedRectangle(cornerRadius: 18)

        if theme.usesGlassyBackground {
            // Glass / Liquid Effect Logic
            ZStack {
                // 1. Native Material Blur
                panelShape
                    .fill(.ultraThinMaterial)
                
                // 2. White Tint for Liquid/Glassy look
                panelShape
                    .fill(Color.white.opacity(0.12))
            }
            // 3. Gradient Border for Light Reflection
            .overlay(
                panelShape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.15),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // 4. Shadow for Depth
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            
        } else {
            // Standard Solid Theme (Black/Cream)
            panelShape
                .fill(theme.backgroundColor.opacity(opacity))
                .overlay(
                    panelShape
                        .stroke(theme.borderColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }

    private func loadImage(path: String) -> NSImage? {
        guard !path.isEmpty else { return nil }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }

    private var titleText: String {
        if !session.activeTask.isEmpty {
            return session.activeTask
        }

        switch session.state {
        case .idle:
            return "Idle"
        case .focusing:
            return "Focus Session"
        case .breaking(let type):
            return type.title
        }
    }

    private var statusColor: Color {
        switch session.state {
        case .idle:
            return .gray
        case .focusing:
            return timer.isRunning ? .green : .orange
        case .breaking:
            return timer.isRunning ? .blue : .orange
        }
    }

    private func format(_ time: TimeInterval) -> String {
        let total = Int(time)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}