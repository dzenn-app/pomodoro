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
                        imagePath = ""
                        showTimerOnImage = true
                        layoutModeID = AppConstants.FloatingLayoutSettings.defaultLayoutID
                        UserDefaults.standard.removeObject(forKey: AppConstants.FloatingLayoutSettings.imageBookmarkKey)
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
            do {
                let bookmark = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: AppConstants.FloatingLayoutSettings.imageBookmarkKey)
            } catch {
                UserDefaults.standard.removeObject(forKey: AppConstants.FloatingLayoutSettings.imageBookmarkKey)
            }
            imagePath = url.path
            showTimerOnImage = true
            layoutModeID = FloatingLayoutMode.mixed.id
        }
    }
}
