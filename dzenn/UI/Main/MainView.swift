// UI/Main/MainView.swift

import SwiftUI

struct MainView: View {
    @State private var selection: SidebarItem? = .general

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.systemImage)
                    .tag(item)
            }
            .listStyle(.sidebar)
        } detail: {
            switch selection ?? .general {
            case .general:
                GeneralSettingsView()
            case .floatingApp:
                FloatingAppSettingsView()
            }
        }
        .frame(minWidth: 700, minHeight: 450)
    }
}

private enum SidebarItem: String, CaseIterable, Identifiable {
    case general
    case floatingApp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .floatingApp:
            return "Floating App"
        }
    }

    var systemImage: String {
        switch self {
        case .general:
            return "gearshape"
        case .floatingApp:
            return "rectangle.on.rectangle"
        }
    }
}

private struct GeneralSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            DurationSelectorView()
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
