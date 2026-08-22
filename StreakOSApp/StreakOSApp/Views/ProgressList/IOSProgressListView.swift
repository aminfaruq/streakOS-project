import SwiftUI
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
            IOSProgressListHeaderView(
                title: titleText,
                completedCount: completedCount,
                totalCount: viewModel.progressItems.count,
                isEditMode: isEditMode
            )
            
            IOSProgressListToolbarView(
                isEditMode: $isEditMode,
                canNavigateBackward: navigationWindow.canNavigateBackward(from: selectedDate),
                canNavigateForward: navigationWindow.canNavigateForward(from: selectedDate),
                isToday: navigationWindow.isToday(selectedDate),
                onBackward: { shiftDay(by: -1) },
                onForward: { shiftDay(by: 1) },
                onToday: { selectedDate = Date() },
                onAdd: { isAddingItem = true }
            )
            
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
    
    // MARK: - Computed properties
    private var completedCount: Int {
        viewModel.progressItems.filter { $0.record?.isCompleted == true }.count
    }
    
    private var isFutureDate: Bool {
        Calendar.current.startOfDay(for: selectedDate) > Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if viewModel.progressItems.isEmpty {
                    IOSProgressListEmptyStateView()
                } else {
                    ForEach(viewModel.progressItems, id: \.item.id) { progress in
                        IOSProgressListItemCard(
                            viewModel: viewModel,
                            progress: progress,
                            selectedDate: selectedDate,
                            isEditMode: $isEditMode,
                            actionedProgress: $actionedProgress,
                            editingProgress: $editingProgress,
                            pendingDelete: $pendingDelete,
                            draggedProgress: $draggedProgress
                        )
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
