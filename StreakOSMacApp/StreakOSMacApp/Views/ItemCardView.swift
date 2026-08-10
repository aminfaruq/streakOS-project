import SwiftUI
import StreakOSFramework

/// PRD §9.3 item card.
struct ItemCardView: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            tapContent
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)

            Spacer(minLength: 0)

            if progress.record?.isCompleted == true {
                idempotentCircle
            } else {
                plusButton
            }
        }
        .padding(12)
        .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: DesignTokens.cardRadius))
    }

    private var tapContent: some View {
        HStack(spacing: 12) {
            iconContainer

            Text(progress.item.name)
                .font(.system(.body, design: .default).weight(.medium))
                .lineLimit(1)

            if let record = progress.record, record.isCompleted {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DesignTokens.accent)
            } else {
                Text(progress.displayText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var iconContainer: some View {
        Text(progress.item.icon)
            .font(.system(size: 26))
            .frame(width: DesignTokens.iconContainerSize, height: DesignTokens.iconContainerSize)
            .background(DesignTokens.accent.opacity(0.12), in: Circle())
    }

    private var plusButton: some View {
        Button(action: onIncrement) {
            Image(systemName: "plus")
                .font(.title3.weight(.semibold))
                .frame(width: DesignTokens.buttonSize, height: DesignTokens.buttonSize)
                .foregroundStyle(DesignTokens.accent)
                .background(
                    Circle()
                        .strokeBorder(DesignTokens.accent, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private var idempotentCircle: some View {
        Circle()
            .fill(DesignTokens.accent)
            .frame(width: DesignTokens.buttonSize, height: DesignTokens.buttonSize)
            .overlay {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    ItemCardView(
        progress: ItemProgress(
            item: Item(id: UUID(), name: "Push Ups", icon: "💪", targetCount: 10, startDate: .snapshot, endDate: nil, displayOrder: 0, createdAt: .snapshot, updatedAt: .snapshot),
            record: nil
        ),
        onIncrement: {},
        onTap: {}
    )
    .padding()
}

private extension Date {
    static var snapshot: Date { Date(timeIntervalSince1970: 1_700_000_000) }
}