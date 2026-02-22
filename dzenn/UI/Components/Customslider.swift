import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double? = nil

    var body: some View {
        GeometryReader { geometry in
            let clampedValue = clampValue(value)
            let progress = (clampedValue - range.lowerBound) / (range.upperBound - range.lowerBound)

            ZStack(alignment: .leading) {
                // 1. Track (Bagian belakang slider)
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                // 2. Fill (Warna progres)
                Capsule()
                    .fill(Color.blue) // Bisa ganti warna sesuai tema Dzenn
                    .frame(width: CGFloat(progress) * geometry.size.width, height: 4)

                // 3. Thumb (Bulat sempurna)
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .offset(x: CGFloat(progress) * geometry.size.width - 7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(with: gesture.location.x, in: geometry.size.width)
                    }
            )
        }
        .frame(height: 20)
    }

    private func updateValue(with xLocation: CGFloat, in totalWidth: CGFloat) {
        let percentage = max(0, min(1, xLocation / totalWidth))
        let newValue = range.lowerBound + (percentage * (range.upperBound - range.lowerBound))
        value = applyStep(newValue)
    }

    private func clampValue(_ input: Double) -> Double {
        min(range.upperBound, max(range.lowerBound, input))
    }

    private func applyStep(_ input: Double) -> Double {
        guard let step else { return clampValue(input) }
        let steps = (input - range.lowerBound) / step
        let rounded = (steps).rounded() * step + range.lowerBound
        return clampValue(rounded)
    }
}
