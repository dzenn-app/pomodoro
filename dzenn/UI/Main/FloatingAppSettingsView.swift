import SwiftUI

struct FloatingAppSettingsView: View {
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey) private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @State private var hasSelectedImage = false

    var body: some View {
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
                    Button("Choose Image...") {}
                    Button("Remove Image") {}
                        .disabled(!hasSelectedImage)
                }

                Text(hasSelectedImage ? "Image selected" : "No image selected")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Toggle("Show timer on top of image", isOn: .constant(true))
                    .disabled(!hasSelectedImage)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            floatingOpacity = clampOpacity(floatingOpacity)
        }
        .onChange(of: floatingOpacity) {
            floatingOpacity = clampOpacity(floatingOpacity)
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
}
