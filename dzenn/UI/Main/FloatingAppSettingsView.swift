import SwiftUI

struct FloatingAppSettingsView: View {
    @AppStorage(AppConstants.FloatingThemeSettings.selectedThemeKey) private var selectedThemeID: String = AppConstants.FloatingThemeSettings.defaultThemeID

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
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
}
