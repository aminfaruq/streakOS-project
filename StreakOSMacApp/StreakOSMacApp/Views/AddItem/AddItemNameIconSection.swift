import SwiftUI
import StreakOSPresentation

/// Add Item form section: choose an icon and name the habit.
struct AddItemNameIconSection: View {
    @ObservedObject var viewModel: ItemFormViewModel

    @State private var isShowingIconPicker = false

    var body: some View {
        AddItemSectionCard(
            icon: "person.crop.circle",
            title: "NAME & ICON",
            description: "Choose an icon and name your habit"
        ) {
            HStack(spacing: 16) {
                Button {
                    isShowingIconPicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 60, height: 60)

                        Text(viewModel.icon.isEmpty ? "✨" : viewModel.icon)
                            .font(.system(size: 30))
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $isShowingIconPicker) {
                    IconPickerView(selectedIcon: $viewModel.icon)
                }

                TextField("Habit Name...", text: $viewModel.name)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .background(
                DesignTokens.card,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
