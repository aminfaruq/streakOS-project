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
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Item")
                .font(.title2.weight(.semibold))

            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text("Icon")
                TextField("", text: $viewModel.icon)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .onChange(of: viewModel.icon) { _, new in
                        if new.count > 1 {
                            viewModel.icon = String(new.suffix(1))
                        }
                    }
            }

            Stepper("Target: \(viewModel.targetCount)", value: $viewModel.targetCount, in: 1...999)

            DatePicker("Start", selection: $viewModel.startDate, displayedComponents: .date)

            Toggle("End date", isOn: endDateToggle)

            if viewModel.endDate != nil {
                DatePicker("End", selection: endDateBinding, displayedComponents: .date)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }

            HStack {
                Button("Cancel", action: onCancel)
                Spacer()
                Button("Save") {
                    if viewModel.canSave {
                        viewModel.save()
                    }
                }
                .disabled(!viewModel.canSave || viewModel.isSaving)
            }
        }
        .padding(24)
        .frame(width: 420)
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
