import SwiftUI
import StreakOSFramework

// MARK: - Count UI
struct IOSCountItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                tapContent
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)

                Spacer(minLength: 0)

                if isEditMode {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .frame(width: IOSDesignTokens.buttonSize, height: IOSDesignTokens.buttonSize)
                } else if progress.record?.isCompleted == true {
                    idempotentCircle
                } else {
                    plusButton
                }
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 4)

                    Capsule()
                        .fill(IOSDesignTokens.accent)
                        .frame(width: max(0, geometry.size.width * progressFraction), height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressFraction)
                }
            }
            .frame(height: 4)
        }
        .padding(20)
        .background(IOSDesignTokens.card, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isEditMode ? 0.98 : 1.0)
    }

    private var tapContent: some View {
        HStack(spacing: 16) {
            iconContainer

            VStack(alignment: .leading, spacing: 6) {
                Text(progress.item.name)
                    .font(.system(size: 19, weight: .bold))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let record = progress.record, record.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(IOSDesignTokens.accent)
                        Text("Completed")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(IOSDesignTokens.accent)
                    } else {
                        Text(progress.displayText)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                    }

                    if let schedule = progress.item.repeatSchedule {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.system(size: 10, weight: .bold))
                            Text(schedule.displayText)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
    }

    private var iconContainer: some View {
        Text(progress.item.icon)
            .font(.system(size: 26))
            .frame(width: 56, height: 56)
            .background(Color.gray.opacity(0.1), in: Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }

    private var plusButton: some View {
        Button(action: onIncrement) {
            Text("+1")
                .font(.system(size: 16, weight: .bold))
                .frame(width: 48, height: 48)
                .foregroundStyle(.primary)
                .background(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color.gray.opacity(0.05)))
                )
        }
        .buttonStyle(.plain)
    }

    private var idempotentCircle: some View {
        Button(action: onDecrement) {
            Circle()
                .fill(IOSDesignTokens.accent)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
        .buttonStyle(.plain)
    }

    private var progressFraction: CGFloat {
        if progress.record?.isCompleted == true { return 1.0 }
        let current = CGFloat(progress.record?.currentCount ?? 0)
        let target = CGFloat(progress.item.targetCount)
        return min(current / target, 1.0)
    }
}
