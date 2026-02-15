import SwiftUI
import UniformTypeIdentifiers

struct FloatingAppSettingsView: View {
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey) private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID
    @AppStorage(AppConstants.FloatingLayoutSettings.imagePathKey) private var imagePath: String = ""
    @AppStorage(AppConstants.FloatingLayoutSettings.showTimerOnImageKey) private var showTimerOnImage: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            themeSection
            Divider()
            imageSection
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            floatingOpacity = clampOpacity(floatingOpacity)
            updateLayoutMode()
        }
        .onChange(of: floatingOpacity) {
            floatingOpacity = clampOpacity(floatingOpacity)
        }
        .onChange(of: imagePath) {
            updateLayoutMode()
        }
        .onChange(of: showTimerOnImage) {
            updateLayoutMode()
        }
    }

    // MARK: - Subviews

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Floating Theme")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                ForEach(FloatingTheme.allCases) { theme in
                    themeSwatch(theme: theme, isSelected: theme.id == selectedThemeID)
                        .onTapGesture {
                            selectedThemeID = theme.id
                        }
                }
            }

            opacityRow
        }
    }

    private var opacityRow: some View {
        HStack(spacing: 12) {
            Text("Opacity")
                .frame(width: 60, alignment: .leading)

            Slider(
                value: $floatingOpacity,
                in: AppConstants.FloatingThemeSettings.minOpacity...AppConstants.FloatingThemeSettings.maxOpacity,
                step: 0.05
            )

            Text("\(Int((floatingOpacity * 100).rounded()))%")
                .monospacedDigit()
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }

    private var imageSection: some View {
        let hasSelectedImage = !imagePath.isEmpty

        return VStack(alignment: .leading, spacing: 10) {
            Text("Floating Image")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                Button("Choose Image...") {
                    pickImage()
                }
                Button("Remove Image") {
                    removeStoredImage()
                }
                .disabled(!hasSelectedImage)
            }

            Text(hasSelectedImage ? (URL(fileURLWithPath: imagePath).lastPathComponent) : "No image selected")
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle("Show timer on top of image", isOn: $showTimerOnImage)
                .disabled(!hasSelectedImage)
        }
    }

    private func themeSwatch(theme: FloatingTheme, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.backgroundColor)
                .frame(width: 90, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : theme.borderColor, lineWidth: isSelected ? 2 : 1)
                )

            Text(theme.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 90)
    }

    private func clampOpacity(_ value: Double) -> Double {
        min(AppConstants.FloatingThemeSettings.maxOpacity,
            max(AppConstants.FloatingThemeSettings.minOpacity, value))
    }

    private func updateLayoutMode() {
        let nextLayoutID: String
        if imagePath.isEmpty {
            nextLayoutID = AppConstants.FloatingLayoutSettings.defaultLayoutID
        } else {
            nextLayoutID = showTimerOnImage ? FloatingLayoutMode.mixed.id : FloatingLayoutMode.imageOnly.id
        }

        guard layoutModeID != nextLayoutID else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            layoutModeID = nextLayoutID
        }
    }

    private func pickImage() {
        FloatingImagePicker.pickImage { url in
            guard let url else { return }
            if let storedPath = FloatingImageStorage.shared.storeImage(from: url) {
                imagePath = storedPath
            } else {
                imagePath = url.path
            }
            showTimerOnImage = true
        }
    }

    private func removeStoredImage() {
        FloatingImageStorage.shared.removeImage(atPath: imagePath)
        imagePath = ""  
        showTimerOnImage = true
    }

}

private enum FloatingImagePicker {
    static func pickImage(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK else {
                completion(nil)
                return
            }
            completion(panel.url)
        }
    }
}
