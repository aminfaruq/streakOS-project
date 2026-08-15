import SwiftUI
import UniformTypeIdentifiers
import StreakOSFramework
import StreakOSPresentation
import Combine

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
            // MARK: - Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("StreakOS")
                        .font(.system(size: 28, weight: .bold)) // sedikit lebih besar
                    
                    Text(titleText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Progress ring diperbesar
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 3.5)
                    
                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(DesignTokens.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progressFraction)
                    
                    Text("\(completedCount)/\(viewModel.progressItems.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 44, height: 44)
                .opacity(isEditMode ? 0.3 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 18)
            
            // MARK: - Toolbar
            HStack(spacing: 12) {
                Button(action: { withAnimation { isEditMode.toggle() } }) {
                    HStack(spacing: 6) {
                        Image(systemName: isEditMode ? "checkmark.circle.fill" : "pencil")
                            .font(.system(size: 14))
                        Text(isEditMode ? "Done" : "Edit")
                            .font(.subheadline.weight(.medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isEditMode ? DesignTokens.accent.opacity(0.1) : Color.gray.opacity(0.08))
                    )
                }
                .buttonStyle(.borderless)
                .foregroundStyle(isEditMode ? DesignTokens.accent : .primary)
                
                Spacer()
                
                // Date Navigation — diberi background & border agar terlihat sebagai kontrol
                HStack(spacing: 8) {
                    Button(action: { shiftDay(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.borderless)
                    .disabled(!navigationWindow.canNavigateBackward(from: selectedDate))
                    
                    if !navigationWindow.isToday(selectedDate) {
                        Button(action: { selectedDate = Date() }) {
                            Text("Today")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 4)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(DesignTokens.accent)
                    } else {
                        Text("Today")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: { shiftDay(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.borderless)
                    .disabled(!navigationWindow.canNavigateForward(from: selectedDate))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignTokens.card)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
                
                Spacer()
                
                Button(action: { isAddingItem = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.accent)
                .clipShape(Circle())
                .shadow(color: DesignTokens.accent.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 24)
            
            // MARK: - Content
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
        .onReceive(
            NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        ) { _ in
            viewModel.load(for: selectedDate)
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
    
    // MARK: - Main Content (UI changes only)
    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) { // spacing dinaikkan dari 10 ke 12
                if viewModel.progressItems.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.progressItems, id: \.item.id) { progress in
                        draggableItemCard(for: progress)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)          // batasi lebar konten agar tidak terlalu melebar
            .frame(maxWidth: .infinity)    // center konten
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
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 56))
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
