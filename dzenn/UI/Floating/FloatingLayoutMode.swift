import SwiftUI

enum FloatingLayoutMode: String, CaseIterable, Identifiable {
    case timerOnly
    case imageOnly
    case mixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timerOnly:
            return "Timer Only"
        case .imageOnly:
            return "Image Only"
        case .mixed:
            return "Mixed"
        }
    }

    var contentSize: CGSize {
        switch self {
        case .timerOnly:
            return CGSize(width: AppConstants.FloatingLayoutSettings.timerOnlyWidth,
                          height: AppConstants.FloatingLayoutSettings.timerOnlyHeight)
        case .imageOnly:
            return CGSize(width: AppConstants.FloatingLayoutSettings.width,
                          height: AppConstants.FloatingLayoutSettings.imageOnlyHeight)
        case .mixed:
            return CGSize(width: AppConstants.FloatingLayoutSettings.width,
                          height: AppConstants.FloatingLayoutSettings.mixedHeight)
        }
    }

    static func from(id: String) -> FloatingLayoutMode {
        FloatingLayoutMode(rawValue: id) ?? .timerOnly
    }
}
