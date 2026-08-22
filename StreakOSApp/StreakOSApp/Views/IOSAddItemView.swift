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
                    // MARK: - 1. Name & Icon
                    sectionCard(
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
                    
                    // MARK: - 2. Habit Type
                    sectionCard(
                        icon: "arrow.triangle.2.circlepath",
                        title: "HABIT TYPE",
                        description: "Choose how you want to track your habit"
                    ) {
                        HStack(spacing: 12) {
                            // Count option
                            Button {
                                viewModel.type = .count
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "number.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(IOSDesignTokens.accent)
                                        Spacer()
                                        if viewModel.type == .count {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(IOSDesignTokens.accent)
                                                .font(.title3)
                                        }
                                    }
                                    Text("Count")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text("Track how many times you complete this habit per day.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(IOSDesignTokens.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            viewModel.type == .count ? IOSDesignTokens.accent : Color.gray.opacity(0.15),
                                            lineWidth: viewModel.type == .count ? 2 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Timer option
                            Button {
                                viewModel.type = .minutes
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "timer.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundStyle(IOSDesignTokens.accent)
                                        Spacer()
                                        if viewModel.type == .minutes {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(IOSDesignTokens.accent)
                                                .font(.title3)
                                        }
                                    }
                                    Text("Timer")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text("Track how many minutes you spend on this habit per day.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(IOSDesignTokens.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            viewModel.type == .minutes ? IOSDesignTokens.accent : Color.gray.opacity(0.15),
                                            lineWidth: viewModel.type == .minutes ? 2 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // MARK: - 3. Period
                    sectionCard(
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
                                
                                DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 44)
                                    .background(
                                        IOSDesignTokens.card,
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                    )
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
                                    DatePicker("", selection: endDateBinding, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .padding(.horizontal, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(height: 44)
                                        .background(
                                            IOSDesignTokens.card,
                                            in: RoundedRectangle(cornerRadius: 12)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                        )
                                } else {
                                    Text("Not set")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.tertiary)
                                        .padding(.horizontal, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(height: 44)
                                        .background(
                                            IOSDesignTokens.card,
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
                    
                    // MARK: - 4. Repeat Schedule
                    sectionCard(
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
                            IOSDesignTokens.card,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // MARK: - 5. Daily Target
                    sectionCard(
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
                                    .foregroundStyle(IOSDesignTokens.accent)
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(
                            IOSDesignTokens.card,
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // MARK: - Error
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.subheadline)
                            Text(errorMessage)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.red)
                        .padding(.top, 4)
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
    
    // MARK: - Helper for section card
    private func sectionCard<Content: View>(
        icon: String,
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(IOSDesignTokens.accent)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            content()
        }
    }
    
    // MARK: - Repeat Schedule Helpers
    private func presetButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? IOSDesignTokens.accent : Color.gray.opacity(0.12))
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
                        .fill(isSelected ? IOSDesignTokens.accent : Color.gray.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? IOSDesignTokens.accent : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
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
                                .background(
                                    selectedIcon == icon
                                    ? Color.gray.opacity(0.2)
                                    : Color.clear,
                                    in: Circle()
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedIcon == icon
                                            ? IOSDesignTokens.accent
                                            : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(IOSDesignTokens.background)
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
