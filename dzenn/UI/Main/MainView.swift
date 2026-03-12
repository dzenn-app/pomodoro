import SwiftUI

struct MainView: View {
    @State private var selection: SidebarItem? = .general
    private let columnBottomPadding: CGFloat = 6
    private let outerSidePadding: CGFloat = 6
    private let columnTopPadding: CGFloat = 6
    private let titlebarInset: CGFloat = 36

    var body: some View {
        HStack(spacing: 2) {
            self.sidebarSection
                .padding(.leading, self.outerSidePadding)
                .padding(.top, self.columnTopPadding)
                .padding(.bottom, self.columnBottomPadding)

            self.detailSection
                .padding(.trailing, self.outerSidePadding)
                .padding(.top, self.columnTopPadding)
                .padding(.bottom, self.columnBottomPadding)
        }
        .frame(minWidth: 720, minHeight: 480)
        .background(self.mainBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .top)
    }

    private var sidebarSection: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: self.titlebarInset)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(SidebarItem.allCases) { item in
                    SidebarRow(item: item, isSelected: self.selection == item)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                self.selection = item
                            }
                        }
                }
                Spacer()
            }
            .padding(10)
        }
        .frame(width: 220)
        .frame(maxHeight: .infinity)
        .background(self.sidebarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    private var detailSection: some View {
        Group {
            switch self.selection ?? .general {
            case .general:
                GeneralSettingsView()
            case .floatingApp:
                FloatingAppSettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(self.mainBackground)
    }

    private var mainBackground: Color {
        .dzennBackground
    }

    private var sidebarBackground: Color {
        .dzennSidebarBackground
    }
}

private struct SidebarRow: View {
    let item: SidebarItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: self.item.systemImage)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 20)

            Text(self.item.title)
                .font(.system(size: 13, weight: .regular))

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(self.isSelected ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}

private enum SidebarItem: String, CaseIterable, Identifiable {
    case general, floatingApp
    var id: String {
        rawValue
    }

    var title: String {
        self == .general ? "General" : "Floating App"
    }

    var systemImage: String {
        self == .general ? "gearshape" : "rectangle.on.rectangle"
    }
}

private struct GeneralSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            DurationSelectorView()
        }
        .padding(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
