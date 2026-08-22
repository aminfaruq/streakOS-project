import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// PRD §4.1 Add Item form.
struct AddItemView: View {
    @ObservedObject var viewModel: ItemFormViewModel
    let onCancel: () -> Void

    init(
        viewModel: ItemFormViewModel,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)

                Spacer()

                VStack(spacing: 2) {
                    Text(viewModel.isEditing ? "Edit Habit" : "New Habit")
                        .font(.headline.weight(.bold))
                    Text("Track your daily routine")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(viewModel.isEditing ? "Done" : "Add") {
                    if viewModel.canSave { viewModel.save() }
                }
                .buttonStyle(.plain)
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(viewModel.canSave ? DesignTokens.accent : Color.gray.opacity(0.4))
                )
                .disabled(!viewModel.canSave || viewModel.isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    AddItemNameIconSection(viewModel: viewModel)
                    AddItemTypeSection(viewModel: viewModel)
                    AddItemPeriodSection(viewModel: viewModel)
                    AddItemRepeatSection(viewModel: viewModel)
                    AddItemTargetSection(viewModel: viewModel)

                    if let errorMessage = viewModel.errorMessage {
                        AddItemErrorMessage(message: errorMessage)
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 420, height: 580)
        .background(DesignTokens.background)
    }
}
