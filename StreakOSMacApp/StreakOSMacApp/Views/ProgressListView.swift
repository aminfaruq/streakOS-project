import SwiftUI
import UniformTypeIdentifiers
import StreakOSFramework
import StreakOSPresentation

/// PRD §9.1/§9.5 main progress screen.
struct ProgressListView: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    let itemCreator: any ItemCreator
    let itemUpdater: any ItemUpdater
    let itemDuplicator: any ItemDuplicator
    
    @State private var selectedDate = Date()
    @State private var isEditMode = false
    @State private var isAddingItem = false
    @State private var actionedProgress: ItemProgress?
    @State private var editingProgress: ItemProgress?
    @State private var pendingDelete: ItemProgress?
    @State private var draggedProgress: ItemProgress?
    
    private var navigationWindow: DateNavigationWindow {
        DateNavigationWindow(today: Date())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            editHeaderButton

            DateHeaderView(
                title: titleText,
                isToday: navigationWindow.isToday(selectedDate),
                canGoBackward: navigationWindow.canNavigateBackward(from: selectedDate),
                canGoForward: navigationWindow.canNavigateForward(from: selectedDate),
                onBackward: { shiftDay(by: -1) },
                onForward: { shiftDay(by: 1) },
                onToday: { selectedDate = Date() }
            )
            
            if viewModel.isLoading && viewModel.progressItems.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                mainContentView
            }
            
            addButton
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(DesignTokens.background)
        .onAppear {
            viewModel.load(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            viewModel.load(for: newDate)
        }
        .sheet(isPresented: $isAddingItem) {
            AddItemView(
                viewModel: ItemFormViewModel(creator: itemCreator) { _ in
                    isAddingItem = false
                    viewModel.load(for: selectedDate)
                },
                onCancel: { isAddingItem = false }
            )
        }
        .sheet(item: $editingProgress) { progress in
            AddItemView(
                viewModel: ItemFormViewModel(updater: itemUpdater, item: progress.item) { updated in
                    editingProgress = nil
                    viewModel.update(progress, with: updated, on: selectedDate)
                },
                onCancel: { editingProgress = nil }
            )
        }
        .popover(item: $actionedProgress) { progress in
            let currentProgress = viewModel.progressItems.first(where: { $0.item.id == progress.item.id }) ?? progress
            ItemActionsView(
                progress: currentProgress,
                onIncrement: {
                    viewModel.increment(currentProgress, on: selectedDate)
                },
                onDecrement: {
                    viewModel.decrement(currentProgress, on: selectedDate)
                },
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
                },
                onCancel: { actionedProgress = nil }
            )
        }
        .confirmationDialog(
            "Delete \(pendingDelete?.item.name ?? "item")?",
            isPresented: Binding(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            presenting: pendingDelete
        ) { _ in
            Button("Delete", role: .destructive) {
                if let progress = pendingDelete {
                    viewModel.delete(progress)
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: { progress in
            Text("This will also delete all history for this item.")
        }
    }
    
    private var editHeaderButton: some View {
        HStack {
            Spacer()
            Button(isEditMode ? "Done" : "Edit") {
                withAnimation { isEditMode.toggle() }
            }
            .buttonStyle(.plain)
            .foregroundStyle(DesignTokens.accent)
            .font(.body.weight(.medium))
        }
        .padding(.bottom, -8)
    }

    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.progressItems.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.progressItems, id: \.item.id) { progress in
                        draggableItemCard(for: progress)
                    }
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func draggableItemCard(for progress: ItemProgress) -> some View {
        ItemCardView(
            progress: progress,
            isEditMode: isEditMode,
            onIncrement: { viewModel.increment(progress, on: selectedDate) },
            onTap: { if !isEditMode { actionedProgress = progress } }
        )
        .onDrag {
            if isEditMode {
                draggedProgress = progress
                return NSItemProvider(object: progress.item.id.uuidString as NSString)
            }
            return NSItemProvider()
        }
        .onDrop(
            of: isEditMode ? [.text] : [],
            delegate: ItemDropDelegate(
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
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📋")
                .font(.system(size: 56))
            Text("No habits yet")
                .font(.title3.weight(.semibold))
            Text("Add your first habit to get started")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 60)
    }
    
    private var addButton: some View {
        Button {
            isAddingItem = true
        } label: {
            Label("Add Item", systemImage: "plus")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(DesignTokens.accent, in: RoundedRectangle(cornerRadius: DesignTokens.cardRadius))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
    
    private var titleText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return navigationWindow.isToday(selectedDate) ? "Today · \(formatter.string(from: selectedDate))" : formatter.string(from: selectedDate)
    }
    
    private func shiftDay(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct ItemDropDelegate: DropDelegate {
    let item: ItemProgress
    @Binding var items: [ItemProgress]
    @Binding var draggedItem: ItemProgress?
    let onMove: (Int, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.item.id != item.item.id,
              let from = items.firstIndex(where: { $0.item.id == draggedItem.item.id }),
              let to = items.firstIndex(where: { $0.item.id == item.item.id }) else {
            return
        }

        if items[to].item.id != draggedItem.item.id {
            withAnimation {
                onMove(from, to)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
