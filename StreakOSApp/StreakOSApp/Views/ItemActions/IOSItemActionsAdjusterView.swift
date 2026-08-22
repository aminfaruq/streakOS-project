import SwiftUI
import StreakOSFramework

struct IOSItemActionsAdjusterView: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("ADJUST")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.title3.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(progress.displayText)
                    .font(.system(size: 20, weight: .bold))
                    .frame(minWidth: 80, alignment: .center)

                Spacer()

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(IOSDesignTokens.accent)
                        .frame(width: 44, height: 44)
                        .background(IOSDesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(IOSDesignTokens.card, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))

            let isRestartDisabled = (progress.record?.currentCount ?? 0) == 0 && progress.record?.timerStartDate == nil

            Button(action: onRestart) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Restart Progress")
                }
                .font(.body.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(isRestartDisabled ? Color.gray.opacity(0.1) : Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(isRestartDisabled ? Color.gray.opacity(0.5) : .orange)
            }
            .buttonStyle(.plain)
            .disabled(isRestartDisabled)
        }
        .padding()
    }
}
