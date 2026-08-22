import SwiftUI
import StreakOSFramework
import StreakOSPresentation

/// Add Item form section: choose the weekly repeat schedule.
struct AddItemRepeatSection: View {
    @ObservedObject var viewModel: ItemFormViewModel

    var body: some View {
        AddItemSectionCard(
            icon: "repeat",
            title: "REPEAT",
            description: "Choose which days this habit repeats"
        ) {
            VStack(spacing: 12) {
                HStack {
                    Text("Repeat Habit")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Toggle("", isOn: $viewModel.isRepeating.animation(.easeInOut(duration: 0.2)))
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .scaleEffect(0.8)
                }

                if viewModel.isRepeating {
                    VStack(spacing: 12) {
                        // Quick Presets
                        HStack(spacing: 8) {
                            presetButton(title: "Every day", isSelected: viewModel.selectedDays.count == 7) {
                                viewModel.setEveryday()
                            }
                            presetButton(title: "Weekdays", isSelected: viewModel.selectedDays == Set([.monday, .tuesday, .wednesday, .thursday, .friday])) {
                                viewModel.setWeekdays()
                            }
                            presetButton(title: "Weekends", isSelected: viewModel.selectedDays == Set([.saturday, .sunday])) {
                                viewModel.setWeekends()
                            }
                        }

                        // Day of week selector
                        HStack(spacing: 6) {
                            ForEach(Weekday.orderedDays, id: \.self) { day in
                                dayButton(day: day)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
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

    private func presetButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignTokens.accent : Color.gray.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }

    private func dayButton(day: Weekday) -> some View {
        let isSelected = viewModel.selectedDays.contains(day)
        return Button {
            viewModel.toggleDay(day)
        } label: {
            Text(day.singleLetter)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? DesignTokens.accent : Color.gray.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? DesignTokens.accent : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
