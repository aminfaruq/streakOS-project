import SwiftUI
import StreakOSPresentation

/// Add Item form section: set the start and end dates.
struct AddItemPeriodSection: View {
    @ObservedObject var viewModel: ItemFormViewModel

    var body: some View {
        AddItemSectionCard(
            icon: "calendar",
            title: "PERIOD",
            description: "Set when this habit starts and ends"
        ) {
            HStack(spacing: 16) {
                // Start Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("STARTS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)

                    AddItemDateField(date: $viewModel.startDate)
                }

                // End Date
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ENDS")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .tracking(1.2)

                        Spacer()

                        Toggle("", isOn: endDateToggle)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    }

                    if viewModel.endDate != nil {
                        AddItemDateField(date: endDateBinding)
                    } else {
                        Text("Not set")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 44)
                            .background(
                                DesignTokens.card,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var endDateToggle: Binding<Bool> {
        Binding(
            get: { viewModel.endDate != nil },
            set: { isOn in
                viewModel.endDate = isOn ? Calendar.current.date(byAdding: .day, value: 1, to: viewModel.startDate) : nil
            }
        )
    }

    private var endDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.endDate ?? viewModel.startDate },
            set: { viewModel.endDate = $0 }
        )
    }
}

/// Styled compact date picker used inside the period section.
private struct AddItemDateField: View {
    @Binding var date: Date

    var body: some View {
        DatePicker("", selection: $date, displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.compact)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
            .background(
                DesignTokens.card,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }
}
