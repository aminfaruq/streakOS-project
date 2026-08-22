import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// Add Item form section: choose count or timer tracking.
struct IOSAddItemTypeSection: View {
    @ObservedObject var viewModel: ItemFormViewModel

    var body: some View {
        IOSAddItemSectionCard(
            icon: "arrow.triangle.2.circlepath",
            title: "HABIT TYPE",
            description: "Choose how you want to track your habit"
        ) {
            HStack(spacing: 12) {
                IOSAddItemTypeOptionButton(
                    icon: "number.circle.fill",
                    title: "Count",
                    subtitle: "Track how many times you complete this habit per day.",
                    isSelected: viewModel.type == .count,
                    onSelect: { viewModel.type = .count }
                )

                IOSAddItemTypeOptionButton(
                    icon: "timer.circle.fill",
                    title: "Timer",
                    subtitle: "Track how many minutes you spend on this habit per day.",
                    isSelected: viewModel.type == .minutes,
                    onSelect: { viewModel.type = .minutes }
                )
            }
        }
    }
}

private struct IOSAddItemTypeOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(IOSDesignTokens.accent)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(IOSDesignTokens.accent)
                            .font(.title3)
                    }
                }
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(IOSDesignTokens.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? IOSDesignTokens.accent : Color.gray.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
