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
            // Modal Header
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .font(.body)
                
                Spacer()
                
                Text(viewModel.isEditing ? "Edit Habit" : "New Habit")
                    .font(.headline.weight(.bold))
                
                Spacer()
                
                Button(viewModel.isEditing ? "Done" : "Add") {
                    if viewModel.canSave { viewModel.save() }
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.canSave ? DesignTokens.accent : .gray)
                .font(.body.weight(.bold))
                .disabled(!viewModel.canSave || viewModel.isSaving)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Name & Icon Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            TextField("", text: $viewModel.icon)
                                .font(.system(size: 30))
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .frame(width: 50)
                                .onChange(of: viewModel.icon) { _, new in
                                    if new.count > 1 {
                                        viewModel.icon = String(new.suffix(1))
                                    }
                                }
                        }
                        
                        TextField("Habit Name...", text: $viewModel.name)
                            .font(.title2.weight(.semibold))
                            .textFieldStyle(.plain)
                    }
                    .padding(16)
                    .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Dates
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("START DATE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .tracking(1.5)
                                .padding(.leading, 4)
                            
                            DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 48)
                                .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("END DATE (OPT)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .tracking(1.5)
                                .padding(.leading, 4)
                            
                            HStack {
                                Toggle("", isOn: endDateToggle)
                                    .labelsHidden()
                                    .toggleStyle(.switch)
                                    .scaleEffect(0.8)
                                
                                if viewModel.endDate != nil {
                                    DatePicker("", selection: endDateBinding, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                } else {
                                    Text("None")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.tertiary)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 48)
                            .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                        }
                    }
                    
                    // Target Stepper
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DAILY TARGET")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                            .padding(.leading, 4)
                        
                        HStack {
                            Button {
                                if viewModel.targetCount > 1 { viewModel.targetCount -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .font(.title3.weight(.bold))
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                TextField("", value: $viewModel.targetCount, formatter: NumberFormatter())
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .textFieldStyle(.plain)
                                    .frame(width: 60)
                                
                                Text("Times")
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
                        .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 460, height: 500)
        .background(DesignTokens.background)
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
