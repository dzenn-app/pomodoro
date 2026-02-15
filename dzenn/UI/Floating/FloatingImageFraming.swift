import CoreGraphics

struct FloatingImageFraming {
    static func clampedNormalized(_ value: CGFloat) -> CGFloat {
        min(1, max(-1, value))
    }

    static func clampedNormalizedOffset(x: Double, y: Double) -> CGSize {
        CGSize(width: clampedNormalized(CGFloat(x)),
               height: clampedNormalized(CGFloat(y)))
    }

    static func renderedSize(imageSize: CGSize, containerSize: CGSize) -> CGSize {
        guard imageSize.width > 0,
              imageSize.height > 0,
              containerSize.width > 0,
              containerSize.height > 0 else {
            return .zero
        }

        let fillScale = max(containerSize.width / imageSize.width,
                            containerSize.height / imageSize.height)
        return CGSize(width: imageSize.width * fillScale,
                      height: imageSize.height * fillScale)
    }

    static func maxOffset(imageSize: CGSize, containerSize: CGSize) -> CGSize {
        let rendered = renderedSize(imageSize: imageSize, containerSize: containerSize)
        return CGSize(width: max((rendered.width - containerSize.width) / 2, 0),
                      height: max((rendered.height - containerSize.height) / 2, 0))
    }

    static func offset(fromNormalized normalized: CGSize,
                       imageSize: CGSize,
                       containerSize: CGSize) -> CGSize {
        let limit = maxOffset(imageSize: imageSize, containerSize: containerSize)
        let x = clampedNormalized(normalized.width) * limit.width
        let y = clampedNormalized(normalized.height) * limit.height
        return CGSize(width: x, height: y)
    }

    static func normalized(fromOffset offset: CGSize,
                           imageSize: CGSize,
                           containerSize: CGSize) -> CGSize {
        let limit = maxOffset(imageSize: imageSize, containerSize: containerSize)

        let normalizedX = limit.width > 0 ? offset.width / limit.width : 0
        let normalizedY = limit.height > 0 ? offset.height / limit.height : 0

        return CGSize(width: clampedNormalized(normalizedX),
                      height: clampedNormalized(normalizedY))
    }
}
