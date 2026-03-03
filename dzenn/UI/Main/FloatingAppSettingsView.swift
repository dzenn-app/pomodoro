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
                appearanceSection
                Divider()
                imageSection
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollIndicators(.visible)
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            floatingOpacity = clampOpacity(floatingOpacity)
            syncDraftOffsetsFromApplied()
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

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Floating Appearance")
                .font(.title3)
                .fontWeight(.semibold)

            opacityRow
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
                value: $floatingOpacity,
                range: opacityRange,
                step: 0.01
            )
            .frame(width: 200)

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

            Text(
                hasSelectedImage
                    ? URL(fileURLWithPath: imagePath).lastPathComponent
                    : "No image selected"
            )
                .font(.caption)
                .foregroundColor(.secondary)

            Toggle("Show timer on top of image", isOn: $showTimerOnImage)
                .disabled(!hasSelectedImage)

            if let image = loadImage(path: imagePath) {
                imagePositioningSection(image: image)
            }
        }
    }

    private func imagePositioningSection(image: NSImage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Image Positioning")
                .font(.headline)

            FloatingImagePositioningPreview(
                image: image,
                previewAspectRatio: previewAspectRatio,
                offsetX: $draftImageOffsetX,
                offsetY: $draftImageOffsetY
            )

            HStack(spacing: 12) {
                Button("Apply Position") {
                    applyDraftPosition()
                }
                .disabled(!hasPendingPositionChanges)

                Button("Reset") {
                    resetDraftPosition()
                }
                .disabled(!hasDraftPosition)
            }

            Text("Floating panel keeps the last applied position until you press Apply Position.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    private var previewAspectRatio: CGFloat {
        AppConstants.FloatingLayoutSettings.width / previewImageHeight
    }

    private var previewImageHeight: CGFloat {
        showTimerOnImage ? AppConstants.FloatingLayoutSettings.mixedImageHeight : AppConstants.FloatingLayoutSettings.imageOnlyHeight
    }

    private var hasPendingPositionChanges: Bool {
        abs(draftImageOffsetX - appliedImageOffsetX) > 0.001
            || abs(draftImageOffsetY - appliedImageOffsetY) > 0.001
    }

    private var hasDraftPosition: Bool {
        abs(draftImageOffsetX) > 0.001 || abs(draftImageOffsetY) > 0.001
    }

    private func clampOpacity(_ value: Double) -> Double {
        min(AppConstants.FloatingThemeSettings.maxOpacity,
            max(AppConstants.FloatingThemeSettings.minOpacity, value))
    }

    private func clampNormalized(_ value: Double) -> Double {
        Double(FloatingImageFraming.clampedNormalized(CGFloat(value)))
    }

    private func syncDraftOffsetsFromApplied() {
        draftImageOffsetX = clampNormalized(appliedImageOffsetX)
        draftImageOffsetY = clampNormalized(appliedImageOffsetY)
    }

    private func applyDraftPosition() {
        appliedImageOffsetX = clampNormalized(draftImageOffsetX)
        appliedImageOffsetY = clampNormalized(draftImageOffsetY)
    }

    private func resetDraftPosition() {
        draftImageOffsetX = AppConstants.FloatingLayoutSettings.defaultImageOffset
        draftImageOffsetY = AppConstants.FloatingLayoutSettings.defaultImageOffset
    }

    private func resetAppliedPosition() {
        appliedImageOffsetX = AppConstants.FloatingLayoutSettings.defaultImageOffset
        appliedImageOffsetY = AppConstants.FloatingLayoutSettings.defaultImageOffset
        resetDraftPosition()
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
            resetAppliedPosition()
        }
    }

    private func removeStoredImage() {
        FloatingImageStorage.shared.removeImage(atPath: imagePath)
        imagePath = ""
        showTimerOnImage = true
        resetAppliedPosition()
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
            let containerSize = CGSize(width: previewWidth, height: previewWidth / previewAspectRatio)
            let normalizedOffset = FloatingImageFraming.clampedNormalizedOffset(x: offsetX, y: offsetY)
            let imageOffset = FloatingImageFraming.offset(fromNormalized: normalizedOffset,
                                                          imageSize: image.size,
                                                          containerSize: containerSize)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))

                Image(nsImage: image)
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
                        let next = CGSize(width: start.width + value.translation.width,
                                          height: start.height + value.translation.height)

                        let limits = FloatingImageFraming.maxOffset(imageSize: image.size, containerSize: containerSize)
                        let clamped = CGSize(width: min(max(next.width, -limits.width), limits.width),
                                             height: min(max(next.height, -limits.height), limits.height))

                        let normalized = FloatingImageFraming.normalized(fromOffset: clamped,
                                                                         imageSize: image.size,
                                                                         containerSize: containerSize)
                        offsetX = normalized.width
                        offsetY = normalized.height
                    }
                    .onEnded { _ in
                        dragStartOffset = nil
                    }
            )
        }
        .frame(width: previewWidth, height: previewWidth / previewAspectRatio)
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
