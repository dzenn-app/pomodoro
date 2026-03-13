import SwiftUI

enum FloatingLayoutMode: String, CaseIterable, Identifiable {
    case timerOnly
    case imageOnly
    case mixed

    var id: String {
        rawValue
    }

    var contentSize: CGSize {
        switch self {
        case .timerOnly:
            CGSize(
                width: AppConstants.FloatingLayoutSettings.timerOnlyWidth,
                height: AppConstants.FloatingLayoutSettings.timerOnlyHeight)
        case .imageOnly:
            CGSize(
                width: AppConstants.FloatingLayoutSettings.width,
                height: AppConstants.FloatingLayoutSettings.imageOnlyHeight)
        case .mixed:
            CGSize(
                width: AppConstants.FloatingLayoutSettings.width,
                height: AppConstants.FloatingLayoutSettings.mixedHeight)
        }
    }

    static func from(id: String) -> FloatingLayoutMode {
        FloatingLayoutMode(rawValue: id) ?? .timerOnly
    }
}
