import SwiftUI
import UniformTypeIdentifiers

struct FloatingAppSettingsView: View {
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey) private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID
    @AppStorage(AppConstants.FloatingLayoutSettings.imagePathKey) private var imagePath: String = ""
    @AppStorage(AppConstants.FloatingLayoutSettings.showTimerOnImageKey) private var showTimerOnImage: Bool = true

    var body: some View {
        let hasSelectedImage = !imagePath.isEmpty

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

            Divider()

            VStack(alignment: .leading, spacing: 10) {
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
        if imagePath.isEmpty {
            layoutModeID = AppConstants.FloatingLayoutSettings.defaultLayoutID
        } else {
            layoutModeID = showTimerOnImage ? FloatingLayoutMode.mixed.id : FloatingLayoutMode.imageOnly.id
        }
    }

    private func pickImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            if let storedPath = copyImageToAppSupport(from: url) {
                imagePath = storedPath
            } else {
                imagePath = url.path
            }
            showTimerOnImage = true
            layoutModeID = FloatingLayoutMode.mixed.id
        }
    }

    private func removeStoredImage() {
        if isAppSupportImagePath(imagePath) {
            try? FileManager.default.removeItem(atPath: imagePath)
        }
        imagePath = ""
        showTimerOnImage = true
        layoutModeID = AppConstants.FloatingLayoutSettings.defaultLayoutID
    }

    private func copyImageToAppSupport(from url: URL) -> String? {
        guard let folder = appSupportImagesFolder() else { return nil }
        let fileExtension = url.pathExtension.isEmpty ? "img" : url.pathExtension
        let fileName = UUID().uuidString + "." + fileExtension
        let destinationURL = folder.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            return destinationURL.path
        } catch {
            return nil
        }
    }

    private func appSupportImagesFolder() -> URL? {
        guard var folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        folder.appendPathComponent("Dzenn", isDirectory: true)
        folder.appendPathComponent("Images", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return folder
        } catch {
            return nil
        }
    }

    private func isAppSupportImagePath(_ path: String) -> Bool {
        guard let folder = appSupportImagesFolder() else { return false }
        return path.hasPrefix(folder.path)
    }
}
