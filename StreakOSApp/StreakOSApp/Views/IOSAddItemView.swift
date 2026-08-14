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
                VStack(spacing: 24) {
                    headerSection
                    
                    VStack(spacing: 16) {
                        typePicker
                        dateSection
                        targetStepper
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(viewModel.isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
    
    // MARK: - Components
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: { showIconPicker = true }) {
                Text(viewModel.icon.isEmpty ? "✨" : viewModel.icon)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
                    .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            
            TextField("Habit Name", text: $viewModel.name)
                .font(.title2.weight(.bold))
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private var typePicker: some View {
        Picker("Habit Type", selection: $viewModel.type) {
            Text("Count").tag(ItemType.count)
            Text("Timer (Minutes)").tag(ItemType.minutes)
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 8)
    }
    
    private var dateSection: some View {
        VStack(spacing: 12) {
            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                .font(.headline)
            
            Divider()
            
            Toggle("End Date", isOn: endDateToggle)
                .font(.headline)
            
            if viewModel.endDate != nil {
                DatePicker("", selection: endDateBinding, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var targetStepper: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.bottom, 4)
            
            Text("DAILY TARGET")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)
            
            HStack {
                Button {
                    if viewModel.targetCount > 1 { viewModel.targetCount -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.title3.weight(.bold))
                        .frame(width: 44, height: 44)
                        .background(Color(UIColor.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    TextField("", text: targetCountBinding)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                    
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
                        .foregroundStyle(Color.blue)
                        .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Bindings
    
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

// MARK: - Icon Picker View

struct IOSIconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    let icons = [
        "✨", "💧", "📚", "🏃‍♂️", "🧘‍♀️", "🏋️", "🍎", "😴", 
        "🎸", "🎨", "✍️", "💻", "🪴", "💊", "🧹", "💰",
        "❤️", "🔥", "🚀", "💡", "🎯", "🏆", "🌟", "✅"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            Text(icon)
                                .font(.system(size: 32))
                                .frame(width: 56, height: 56)
                                .background(selectedIcon == icon ? Color.gray.opacity(0.2) : Color.clear, in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
