import SwiftUI
import UniformTypeIdentifiers

struct FloatingAppSettingsView: View {
    @AppStorage(AppConstants.FloatingThemeSettings.opacityKey)
    private var floatingOpacity: Double = AppConstants.FloatingThemeSettings.defaultOpacity
    @AppStorage(AppConstants.FloatingLayoutSettings.selectedLayoutKey)
    private var layoutModeID: String = AppConstants.FloatingLayoutSettings.defaultLayoutID
    @AppStorage(AppConstants.FloatingLayoutSettings.imagePathKey)
    private var imagePath: String = ""
    @AppStorage(AppConstants.FloatingLayoutSettings.showTimerOnImageKey)
    private var showTimerOnImage: Bool = true
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetXKey)
    private var appliedImageOffsetX: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset
    @AppStorage(AppConstants.FloatingLayoutSettings.imageOffsetYKey)
    private var appliedImageOffsetY: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset

    @State private var draftImageOffsetX: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset
    @State private var draftImageOffsetY: Double = AppConstants.FloatingLayoutSettings.defaultImageOffset

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                self.appearanceSection
                Divider()
                self.imageSection
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.visible)
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            self.floatingOpacity = self.clampOpacity(self.floatingOpacity)
            self.syncDraftOffsetsFromApplied()
            self.updateLayoutMode()
        }
        .onChange(of: self.floatingOpacity) {
            self.floatingOpacity = self.clampOpacity(self.floatingOpacity)
        }
        .onChange(of: self.imagePath) {
            self.updateLayoutMode()
        }
        .onChange(of: self.showTimerOnImage) {
            self.updateLayoutMode()
        }
    }

    // MARK: - Subviews

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Floating Appearance")
                .font(.title3)
                .fontWeight(.semibold)

            self.opacityRow
        }
    }

    private var opacityRow: some View {
        HStack(spacing: 12) {
            Text("Opacity")
                .frame(width: 60, alignment: .leading)

            let minOpacity = AppConstants.FloatingThemeSettings.minOpacity
            let maxOpacity = AppConstants.FloatingThemeSettings.maxOpacity
            let opacityRange = minOpacity...maxOpacity
            CustomSlider(
                value: self.$floatingOpacity,
                range: opacityRange,
                step: 0.01)
                .frame(width: 200)

            Text("\(Int((self.floatingOpacity * 100).rounded()))%")
                .monospacedDigit()
                .foregroundColor(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }

    private var imageSection: some View {
        let hasSelectedImage = !self.imagePath.isEmpty

        return VStack(alignment: .leading, spacing: 10) {
            Text("Floating Image")
                .font(.title3)
                .fontWeight(.semibold)
            Text(
                "Recommended size: 1200x800. If you don't have it, no worries, we still compramize"
            )
            .font(.caption2)
            .foregroundColor(.secondary)
            .opacity(0.75)

            HStack(spacing: 12) {
                Button("Choose Image...") {
                    self.pickImage()
                }
                Button("Remove Image") {
                    self.removeStoredImage()
                }
                .disabled(!hasSelectedImage)
            }

            Text(
                hasSelectedImage
                    ? URL(fileURLWithPath: self.imagePath).lastPathComponent
                    : "No image selected")
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle("Show timer on top of image", isOn: self.$showTimerOnImage)
                .disabled(!hasSelectedImage)

            if let image = loadImage(path: imagePath) {
                self.imagePositioningSection(image: image)
            }
        }
    }

    private func imagePositioningSection(image: NSImage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Image Positioning")
                .font(.headline)

            FloatingImagePositioningPreview(
                image: image,
                previewAspectRatio: self.previewAspectRatio,
                offsetX: self.$draftImageOffsetX,
                offsetY: self.$draftImageOffsetY)

            HStack(spacing: 12) {
                Button("Apply Position") {
                    self.applyDraftPosition()
                }
                .disabled(!self.hasPendingPositionChanges)

                Button("Reset") {
                    self.resetDraftPosition()
                }
                .disabled(!self.hasDraftPosition)
            }

            Text("Floating panel keeps the last applied position until you press Apply Position.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    private var previewAspectRatio: CGFloat {
        AppConstants.FloatingLayoutSettings.width / self.previewImageHeight
    }

    private var previewImageHeight: CGFloat {
        self.showTimerOnImage ? AppConstants.FloatingLayoutSettings.mixedImageHeight : AppConstants
            .FloatingLayoutSettings.imageOnlyHeight
    }

    private var hasPendingPositionChanges: Bool {
        abs(self.draftImageOffsetX - self.appliedImageOffsetX) > 0.001
            || abs(self.draftImageOffsetY - self.appliedImageOffsetY) > 0.001
    }

    private var hasDraftPosition: Bool {
        abs(self.draftImageOffsetX) > 0.001 || abs(self.draftImageOffsetY) > 0.001
    }

    private func clampOpacity(_ value: Double) -> Double {
        min(
            AppConstants.FloatingThemeSettings.maxOpacity,
            max(AppConstants.FloatingThemeSettings.minOpacity, value))
    }

    private func clampNormalized(_ value: Double) -> Double {
        Double(FloatingImageFraming.clampedNormalized(CGFloat(value)))
    }

    private func syncDraftOffsetsFromApplied() {
        self.draftImageOffsetX = self.clampNormalized(self.appliedImageOffsetX)
        self.draftImageOffsetY = self.clampNormalized(self.appliedImageOffsetY)
    }

    private func applyDraftPosition() {
        self.appliedImageOffsetX = self.clampNormalized(self.draftImageOffsetX)
        self.appliedImageOffsetY = self.clampNormalized(self.draftImageOffsetY)
    }

    private func resetDraftPosition() {
        self.draftImageOffsetX = AppConstants.FloatingLayoutSettings.defaultImageOffset
        self.draftImageOffsetY = AppConstants.FloatingLayoutSettings.defaultImageOffset
    }

    private func resetAppliedPosition() {
        self.appliedImageOffsetX = AppConstants.FloatingLayoutSettings.defaultImageOffset
        self.appliedImageOffsetY = AppConstants.FloatingLayoutSettings.defaultImageOffset
        self.resetDraftPosition()
    }

    private func updateLayoutMode() {
        let nextLayoutID: String = if self.imagePath.isEmpty {
            AppConstants.FloatingLayoutSettings.defaultLayoutID
        } else {
            self.showTimerOnImage ? FloatingLayoutMode.mixed.id : FloatingLayoutMode.imageOnly.id
        }

        guard self.layoutModeID != nextLayoutID else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            self.layoutModeID = nextLayoutID
        }
    }

    private func pickImage() {
        FloatingImagePicker.pickImage { url in
            guard let url else { return }
            if let storedPath = FloatingImageStorage.shared.storeImage(from: url) {
                self.imagePath = storedPath
            } else {
                self.imagePath = url.path
            }
            self.showTimerOnImage = true
            self.resetAppliedPosition()
        }
    }

    private func removeStoredImage() {
        FloatingImageStorage.shared.removeImage(atPath: self.imagePath)
        self.imagePath = ""
        self.showTimerOnImage = true
        self.resetAppliedPosition()
    }

    private func loadImage(path: String) -> NSImage? {
        guard !path.isEmpty else { return nil }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return NSImage(contentsOfFile: path)
    }
}

private struct FloatingImagePositioningPreview: View {
    let image: NSImage
    let previewAspectRatio: CGFloat
    @Binding var offsetX: Double
    @Binding var offsetY: Double

    @State private var dragStartOffset: CGSize?

    private let previewWidth: CGFloat = 280

    var body: some View {
        GeometryReader { _ in
            let containerSize = CGSize(width: previewWidth, height: previewWidth / self.previewAspectRatio)
            let normalizedOffset = FloatingImageFraming.clampedNormalizedOffset(x: self.offsetX, y: self.offsetY)
            let imageOffset = FloatingImageFraming.offset(
                fromNormalized: normalizedOffset,
                imageSize: self.image.size,
                containerSize: containerSize)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))

                Image(nsImage: self.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: containerSize.width, height: containerSize.height)
                    .offset(x: imageOffset.width, y: imageOffset.height)
                    .frame(width: containerSize.width, height: containerSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)

                Text("Drag to reposition")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: containerSize.width, height: containerSize.height)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if dragStartOffset == nil {
                            dragStartOffset = imageOffset
                        }
                        guard let dragStartOffset else { return }

                        let start = dragStartOffset
                        let next = CGSize(
                            width: start.width + value.translation.width,
                            height: start.height + value.translation.height)

                        let limits = FloatingImageFraming.maxOffset(
                            imageSize: self.image.size,
                            containerSize: containerSize)
                        let clamped = CGSize(
                            width: min(max(next.width, -limits.width), limits.width),
                            height: min(max(next.height, -limits.height), limits.height))

                        let normalized = FloatingImageFraming.normalized(
                            fromOffset: clamped,
                            imageSize: self.image.size,
                            containerSize: containerSize)
                        self.offsetX = normalized.width
                        self.offsetY = normalized.height
                    }
                    .onEnded { _ in
                        self.dragStartOffset = nil
                    })
        }
        .frame(width: self.previewWidth, height: self.previewWidth / self.previewAspectRatio)
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
