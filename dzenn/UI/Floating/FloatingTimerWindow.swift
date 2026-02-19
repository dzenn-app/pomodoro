import SwiftUI

struct FloatingTimerView: View {
    @ObservedObject private var timer = FocusSessionManager.shared.timerService
    
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey) private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID
    @AppStorage(AppConstants.FloatingLayoutSettings.imagePathKey) private var imagePath: String = ""
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetXKey) private var imageOffsetX: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetYKey) private var imageOffsetY: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset

    var body: some View {
        let theme: FloatingTheme = .black
        let clampedOpacity = min(AppConstants.FloatingThemeSettings.maxOpacity,
                                 max(AppConstants.FloatingThemeSettings.minOpacity, floatingOpacity))
        let layoutMode = FloatingLayoutMode.from(id: layoutModeID)

        Group {
            switch layoutMode {
            case .timerOnly:
                timerOnlyContent(theme: theme)
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
        .frame(width: layoutMode.contentSize.width)
        .background(panelBackground(theme: theme, opacity: clampedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .animation(.easeInOut(duration: 0.2), value: floatingOpacity)
        .onAppear {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
        .onChange(of: layoutModeID) {
            WindowManager.shared.updateFloatingSize(mode: layoutMode)
        }
    }

    private func timerOnlyContent(theme: FloatingTheme) -> some View {
        Text(format(timer.remainingTime))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(theme.textColor)
            .monospacedDigit()
            .padding(.horizontal, 2)
            .padding(.vertical, 8)
    }

    private func timerContent(theme: FloatingTheme) -> some View {
        HStack {
            Spacer()
            Text(format(timer.remainingTime))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .monospacedDigit()
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 0)
        .frame(maxHeight: .infinity)
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

        panelShape
            .fill(theme.backgroundColor.opacity(opacity))
            .overlay(
                panelShape
                    .stroke(theme.borderColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private func loadImage(path: String) -> NSImage? {
        guard !path.isEmpty else { return nil }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }

    private func format(_ time: TimeInterval) -> String {
        let total = Int(time)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
