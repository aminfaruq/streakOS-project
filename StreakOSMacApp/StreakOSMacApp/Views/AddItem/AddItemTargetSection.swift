import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// Add Item form section: set the daily target count.
struct AddItemTargetSection: View {
    @ObservedObject var viewModel: ItemFormViewModel

    var body: some View {
        AddItemSectionCard(
            icon: "target",
            title: "DAILY TARGET",
            description: viewModel.type == .count
                ? "How many times do you want to complete it per day?"
                : "How many minutes do you want to spend per day?"
        ) {
            HStack {
                Button {
                    if viewModel.targetCount > 1 { viewModel.targetCount -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(alignment: .center, spacing: 4) {
                    TextField("", text: targetCountBinding)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .frame(width: 60)

                    Text(viewModel.type == .minutes ? "Minutes" : "Times")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    if viewModel.targetCount < 999 { viewModel.targetCount += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DesignTokens.accent)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
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

    private var targetCountBinding: Binding<String> {
        Binding(
            get: { String(viewModel.targetCount) },
            set: { newValue in
                let digits = newValue.filter(\.isNumber)
                let clamped = max(1, min(Int(digits) ?? 1, 999))
                viewModel.targetCount = clamped
            }
        )
    }
}
