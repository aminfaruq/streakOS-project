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
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("StreakOS")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .tracking(-0.5)
                    
                    Text(titleText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Activity Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    
                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(DesignTokens.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progressFraction)
                    
                    Text("\(completedCount)/\(viewModel.progressItems.count)")
                        .font(.system(size: 11, weight: .bold))
                }
                .frame(width: 44, height: 44)
                .opacity(isEditMode ? 0.3 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Actions Row (Edit, Date Nav, Add)
            HStack {
                Button(action: { withAnimation { isEditMode.toggle() } }) {
                    Text(isEditMode ? "Done" : "Edit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Mini Date Navigation
                HStack(spacing: 12) {
                    Button(action: { shiftDay(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(navigationWindow.canNavigateBackward(from: selectedDate) ? .primary : .tertiary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!navigationWindow.canNavigateBackward(from: selectedDate))
                    
                    if !navigationWindow.isToday(selectedDate) {
                        Button("Today") { selectedDate = Date() }
                            .font(.system(size: 12, weight: .bold))
                            .buttonStyle(.plain)
                            .foregroundStyle(DesignTokens.accent)
                    } else {
                        Text("Today")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: { shiftDay(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(navigationWindow.canNavigateForward(from: selectedDate) ? .primary : .tertiary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!navigationWindow.canNavigateForward(from: selectedDate))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1), in: Capsule())
                
                Spacer()
                
                Button(action: { isAddingItem = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            if viewModel.isLoading && viewModel.progressItems.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                mainContentView
            }
        }
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
    
    private var completedCount: Int {
        viewModel.progressItems.filter { $0.record?.isCompleted == true }.count
    }
    
    private var progressFraction: Double {
        let total = viewModel.progressItems.count
        guard total > 0 else { return 0 }
        return Double(completedCount) / Double(total)
    }
    
    private var isFutureDate: Bool {
        Calendar.current.startOfDay(for: selectedDate) > Calendar.current.startOfDay(for: Date())
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
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .opacity(isFutureDate ? 0.5 : 1.0)
            .grayscale(isFutureDate ? 0.8 : 0)
            .disabled(isFutureDate)
        }
    }
    
    @ViewBuilder
    private func draggableItemCard(for progress: ItemProgress) -> some View {
        ItemCardView(
            progress: progress,
            isEditMode: isEditMode,
            onIncrement: { viewModel.increment(progress, on: selectedDate) },
            onDecrement: { viewModel.decrement(progress, on: selectedDate) },
            onToggleTimer: { viewModel.toggleTimer(for: progress, on: selectedDate) },
            onTap: { if !isEditMode { actionedProgress = progress } }
        )
        .popover(
            isPresented: Binding(
                get: { actionedProgress?.item.id == progress.item.id },
                set: { if !$0 && actionedProgress?.item.id == progress.item.id { actionedProgress = nil } }
            ),
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .trailing
        ) {
            if let currentProgress = viewModel.progressItems.first(where: { $0.item.id == progress.item.id }) ?? (actionedProgress?.item.id == progress.item.id ? progress : nil) {
                ItemActionsView(
                    progress: currentProgress,
                    onIncrement: { viewModel.increment(currentProgress, on: selectedDate) },
                    onDecrement: { viewModel.decrement(currentProgress, on: selectedDate) },
                    onToggleTimer: { viewModel.toggleTimer(for: currentProgress, on: selectedDate) },
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
                    },
                    onCancel: { actionedProgress = nil }
                )
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
