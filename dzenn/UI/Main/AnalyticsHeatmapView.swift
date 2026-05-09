import SwiftUI

struct AnalyticsHeatmapView: View {
    let cells: [AnalyticsHeatmapCell]
    @Binding var selectedDate: Date

    private let intensityColors: [Color] = [
        Color.gray.opacity(0.15),
        Color.green.opacity(0.28),
        Color.green.opacity(0.45),
        Color.green.opacity(0.62),
        Color.green.opacity(0.78),
        Color.green,
    ]
    private let cellSize: CGFloat = 16
    private let cellSpacing: CGFloat = 4

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    var body: some View {
        SettingsSurfaceCard {
            VStack(alignment: .leading, spacing: 18) {
                SettingsSectionHeading(
                    title: "Focus Heatmap",
                    subtitle: "Weekly columns across recent months. Click day to inspect activity.")

                if self.weekColumns.isEmpty {
                    Text("No focus history yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        self.monthAxis

                        HStack(alignment: .top, spacing: self.cellSpacing) {
                            self.weekdayAxis

                            HStack(alignment: .top, spacing: self.cellSpacing) {
                                ForEach(Array(self.weekColumns.enumerated()), id: \.offset) { _, week in
                                    VStack(spacing: self.cellSpacing) {
                                        ForEach(week, id: \.id) { cell in
                                            self.heatmapCell(cell)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    self.legend
                }
            }
        }
    }

    private var weekColumns: [[AnalyticsHeatmapCell]] {
        self.cells.chunked(into: 7)
    }

    private var monthAxis: some View {
        HStack(alignment: .center, spacing: self.cellSpacing) {
            Color.clear
                .frame(width: 26)

            HStack(alignment: .center, spacing: self.cellSpacing) {
                ForEach(Array(self.weekColumns.enumerated()), id: \.offset) { index, week in
                    let label = self.monthLabel(for: week, index: index)
                    Text(label ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: self.cellSize, alignment: .leading)
                }
            }
        }
    }

    private var weekdayAxis: some View {
        VStack(spacing: self.cellSpacing) {
            ForEach(self.weekdayLabels.indices, id: \.self) { index in
                Text(self.weekdayLabels[index])
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 26, height: self.cellSize, alignment: .leading)
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 12) {
            Text("Less")
                .font(.caption2)
                .foregroundColor(.secondary)

            ForEach(self.intensityColors.indices, id: \.self) { level in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(self.intensityColors[level])
                    .frame(width: 12, height: 12)
            }

            Text("More")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private func heatmapCell(_ cell: AnalyticsHeatmapCell) -> some View {
        let isSelected = Calendar.current.isDate(cell.date, inSameDayAs: self.selectedDate)

        return Button {
            self.selectedDate = cell.date
        } label: {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(self.intensityColors[cell.intensityLevel])
                .frame(width: self.cellSize, height: self.cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(
                            isSelected ? Color.white.opacity(0.9) : Color.secondary.opacity(0.16),
                            lineWidth: isSelected ? 1.6 : 0.5))
        }
        .buttonStyle(.plain)
        .help("\(self.formatDate(cell.date)): \(Int(cell.focusSeconds / 60))m focus")
    }

    private func monthLabel(for week: [AnalyticsHeatmapCell], index: Int) -> String? {
        guard let firstDay = week.first?.date else { return nil }

        if index == 0 {
            return Self.monthFormatter.string(from: firstDay)
        }

        guard let previousWeek = self.weekColumns[safe: index - 1],
              let previousDay = previousWeek.first?.date else {
            return Self.monthFormatter.string(from: firstDay)
        }

        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: firstDay)
        let previousMonth = calendar.component(.month, from: previousDay)
        if currentMonth != previousMonth {
            return Self.monthFormatter.string(from: firstDay)
        }

        return nil
    }

    private func formatDate(_ date: Date) -> String {
        Self.dayFormatter.string(from: date)
    }

    private var weekdayLabels: [String] {
        let calendar = Calendar.current
        let labels = calendar.shortWeekdaySymbols
        let shift = max(calendar.firstWeekday - 1, 0)
        return (Array(labels[shift...]) + Array(labels[..<shift])).map { String($0.prefix(3)) }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }

    subscript(safe index: Int) -> Element? {
        guard self.indices.contains(index) else { return nil }
        return self[index]
    }
}
