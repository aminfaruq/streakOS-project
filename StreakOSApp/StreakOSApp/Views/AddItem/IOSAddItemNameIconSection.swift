import SwiftUI
import StreakOSPresentation

/// Add Item form section: choose an icon and name the habit.
struct IOSAddItemNameIconSection: View {
    @ObservedObject var viewModel: ItemFormViewModel
    @Binding var showIconPicker: Bool

    var body: some View {
        IOSAddItemSectionCard(
            icon: "person.crop.circle",
            title: "NAME & ICON",
            description: "Choose an icon and name your habit"
        ) {
            HStack(spacing: 16) {
                Button {
                    showIconPicker = true
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

                TextField("Habit Name", text: $viewModel.name)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.plain)
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .background(
                IOSDesignTokens.card,
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
