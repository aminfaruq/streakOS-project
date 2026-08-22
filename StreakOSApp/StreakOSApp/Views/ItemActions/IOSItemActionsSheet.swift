import SwiftUI
import StreakOSFramework

struct IOSItemActionsSheet: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRestart: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator for iOS sheet
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)

            IOSItemActionsHeaderView(progress: progress)
            Divider()

            IOSItemActionsAdjusterView(
                progress: progress,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onRestart: { onRestart(); dismiss() }
            )
            Divider()

            IOSItemActionsActionListView(
                onEdit: { dismiss(); onEdit() },
                onDuplicate: { dismiss(); onDuplicate() },
                onDelete: { dismiss(); onDelete() }
            )

            Spacer(minLength: 0)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden) // we made our own above for better control
        .background(IOSDesignTokens.background)
    }
}
