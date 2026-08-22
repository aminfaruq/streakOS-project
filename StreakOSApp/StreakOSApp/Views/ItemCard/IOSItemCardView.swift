import SwiftUI
import StreakOSFramework

struct IOSItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool = false
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    let onTap: () -> Void

    var body: some View {
        if progress.item.type == .minutes {
            IOSTimerItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onToggleTimer: onToggleTimer,
                onTap: onTap
            )
        } else {
            IOSCountItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onTap: onTap
            )
        }
    }
}
