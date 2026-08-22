import SwiftUI
import UniformTypeIdentifiers
import StreakOSFramework
import StreakOSPresentation

/// Draggable item card with actions sheet and drag-and-drop reordering.
struct IOSProgressListItemCard: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    let progress: ItemProgress
    let selectedDate: Date
    @Binding var isEditMode: Bool
    @Binding var actionedProgress: ItemProgress?
    @Binding var editingProgress: ItemProgress?
    @Binding var pendingDelete: ItemProgress?
    @Binding var draggedProgress: ItemProgress?
    
    var body: some View {
        IOSItemCardView(
            progress: progress,
            isEditMode: isEditMode,
            onIncrement: { viewModel.increment(progress, on: selectedDate) },
            onDecrement: { viewModel.decrement(progress, on: selectedDate) },
            onToggleTimer: { viewModel.toggleTimer(for: progress, on: selectedDate) },
            onTap: { if !isEditMode { actionedProgress = progress } }
        )
        .sheet(
            isPresented: Binding(
                get: { actionedProgress?.item.id == progress.item.id },
                set: { if !$0 && actionedProgress?.item.id == progress.item.id { actionedProgress = nil } }
            )
        ) {
            if let currentProgress = viewModel.progressItems.first(where: { $0.item.id == progress.item.id }) ?? (actionedProgress?.item.id == progress.item.id ? progress : nil) {
                IOSItemActionsSheet(
                    progress: currentProgress,
                    onIncrement: { viewModel.increment(currentProgress, on: selectedDate) },
                    onDecrement: { viewModel.decrement(currentProgress, on: selectedDate) },
                    onRestart: { viewModel.restart(for: currentProgress, on: selectedDate) },
                    onEdit: {
                        actionedProgress = nil
                        editingProgress = currentProgress
                    },
                    onDuplicate: {
                        actionedProgress = nil
                        viewModel.duplicate(currentProgress, on: selectedDate)
                    },
                    onDelete: {
                        actionedProgress = nil
                        pendingDelete = currentProgress
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .onDrag {
            if isEditMode {
                draggedProgress = progress
                return NSItemProvider(object: progress.item.id.uuidString as NSString)
            }
            return NSItemProvider()
        }
        .onDrop(
            of: isEditMode ? [.text] : [],
            delegate: IOSItemDropDelegate(
                item: progress,
                items: Binding(
                    get: { viewModel.progressItems },
                    set: { viewModel.updateItemsLocally($0) }
                ),
                draggedItem: $draggedProgress,
                onMove: { from, to in
                    viewModel.reorder(from: from, to: to, on: selectedDate)
                }
            )
        )
    }
}
