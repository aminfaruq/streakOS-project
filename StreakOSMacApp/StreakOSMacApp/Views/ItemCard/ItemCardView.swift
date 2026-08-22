import SwiftUI
import StreakOSFramework

/// PRD §9.3 item card wrapper that functionally separates Count and Timer UI.
struct ItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool = false
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    let onTap: () -> Void

    var body: some View {
        if progress.item.type == .minutes {
            TimerItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onToggleTimer: onToggleTimer,
                onTap: onTap
            )
        } else {
            CountItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onTap: onTap
            )
        }
    }
}
