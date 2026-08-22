import SwiftUI
import StreakOSFramework
import StreakOSPresentation

struct IOSAddItemView: View {
    @ObservedObject var viewModel: ItemFormViewModel
    let onCancel: () -> Void

    @State private var showIconPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    IOSAddItemNameIconSection(viewModel: viewModel, showIconPicker: $showIconPicker)
                    IOSAddItemTypeSection(viewModel: viewModel)
                    IOSAddItemPeriodSection(viewModel: viewModel)
                    IOSAddItemRepeatSection(viewModel: viewModel)
                    IOSAddItemTargetSection(viewModel: viewModel)

                    if let errorMessage = viewModel.errorMessage {
                        IOSAddItemErrorMessage(message: errorMessage)
                    }
                }
                .padding(20)
            }
            .background(IOSDesignTokens.background)
            .navigationTitle(viewModel.isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Done" : "Add") {
                        if viewModel.canSave { viewModel.save() }
                    }
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IOSIconPickerView(selectedIcon: $viewModel.icon)
                    .presentationDetents([.medium])
            }
        }
    }
}
