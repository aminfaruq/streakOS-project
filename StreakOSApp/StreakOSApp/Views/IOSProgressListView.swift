import SwiftUI
import UniformTypeIdentifiers
import StreakOSFramework
import StreakOSPresentation
import CoreData
import Combine

struct IOSProgressListView: View {
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
            // MARK: - Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("StreakOS")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .tracking(-0.5)
                    
                    Text(titleText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    
                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(
                            IOSDesignTokens.accent,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progressFraction)
                    
                    Text("\(completedCount)/\(viewModel.progressItems.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 48, height: 48)
                .opacity(isEditMode ? 0.3 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // MARK: - Actions Row
            HStack(spacing: 12) {
                Button(action: { withAnimation { isEditMode.toggle() } }) {
                    HStack(spacing: 6) {
                        Image(systemName: isEditMode ? "checkmark.circle.fill" : "pencil")
                            .font(.system(size: 15))
                        Text(isEditMode ? "Done" : "Edit")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                isEditMode
                                ? IOSDesignTokens.accent.opacity(0.15)
                                : Color.gray.opacity(0.08)
                            )
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(isEditMode ? IOSDesignTokens.accent : .primary)
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button(action: { shiftDay(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                navigationWindow.canNavigateBackward(from: selectedDate)
                                ? .primary
                                : .tertiary
                            )
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .disabled(!navigationWindow.canNavigateBackward(from: selectedDate))
                    
                    if !navigationWindow.isToday(selectedDate) {
                        Button("Today") {
                            selectedDate = Date()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .buttonStyle(.plain)
                        .foregroundStyle(IOSDesignTokens.accent)
                    } else {
                        Text("Today")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: { shiftDay(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                navigationWindow.canNavigateForward(from: selectedDate)
                                ? .primary
                                : .tertiary
                            )
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                    .disabled(!navigationWindow.canNavigateForward(from: selectedDate))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(IOSDesignTokens.card)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
                
                Spacer()
                Spacer()
                
                Button(action: { isAddingItem = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(IOSDesignTokens.accent)
                                .shadow(color: IOSDesignTokens.accent.opacity(0.3), radius: 3, x: 0, y: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 20)
            
            // MARK: - Content
            if viewModel.isLoading && viewModel.progressItems.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                mainContentView
            }
        }
        .background(IOSDesignTokens.background)
        .onAppear {
            print("Remote change detected on iOS!"); viewModel.load(for: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            viewModel.load(for: newDate)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        ) { _ in
            viewModel.load(for: selectedDate)
        }
        .sheet(isPresented: $isAddingItem) {
            IOSAddItemView(
                viewModel: ItemFormViewModel(creator: itemCreator) { _ in
                    isAddingItem = false
                    print("Remote change detected on iOS!"); viewModel.load(for: selectedDate)
                },
                onCancel: { isAddingItem = false }
            )
        }
        .sheet(item: $editingProgress) { progress in
            IOSAddItemView(
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
    
    // MARK: - Computed properties (unchanged)
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
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if viewModel.progressItems.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.progressItems, id: \.item.id) { progress in
                        draggableItemCard(for: progress)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .opacity(isFutureDate ? 0.5 : 1.0)
            .grayscale(isFutureDate ? 0.8 : 0)
            .disabled(isFutureDate)
        }
    }
    
    @ViewBuilder
    private func draggableItemCard(for progress: ItemProgress) -> some View {
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
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 52))
                .foregroundStyle(.tertiary)
            Text("No habits yet")
                .font(.title3.weight(.semibold))
            Text("Add your first habit to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
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

// MARK: - Drop Delegate (tidak diubah)
struct IOSItemDropDelegate: DropDelegate {
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
