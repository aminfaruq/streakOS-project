import SwiftUI
import StreakOSFramework

/// PRD §4.4 action sheet equivalent (Mac) — Edit / Duplicate / Delete.
struct ItemActionsView: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    let onRestart: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ItemActionsHeaderView(progress: progress)
            Divider()

            ItemActionsAdjusterView(
                progress: progress,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onRestart: onRestart
            )
            Divider()

            ItemActionsActionListView(
                onEdit: onEdit,
                onDuplicate: onDuplicate,
                onDelete: onDelete
            )
        }
        .frame(width: 280)
    }
}
