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
    
    @State private var isShowingIconPicker = false
    
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
                    
                    // MARK: - 1. Name & Icon
                    sectionCard(
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
                                            .foregroundStyle(DesignTokens.accent)
                                        Spacer()
                                        if viewModel.type == .count {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(DesignTokens.accent)
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
                                        .fill(DesignTokens.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            viewModel.type == .count ? DesignTokens.accent : Color.gray.opacity(0.15),
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
                                            .foregroundStyle(DesignTokens.accent)
                                        Spacer()
                                        if viewModel.type == .minutes {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(DesignTokens.accent)
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
                                        .fill(DesignTokens.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            viewModel.type == .minutes ? DesignTokens.accent : Color.gray.opacity(0.15),
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
                                        DesignTokens.card,
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
                                            DesignTokens.card,
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
                    
                    // MARK: - 4. Daily Target
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
                .padding(24)
            }
        }
        .frame(width: 420, height: 540)
        .background(DesignTokens.background)
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
                    .foregroundStyle(DesignTokens.accent)
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
    
    // MARK: - Bindings (tidak diubah)
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

// MARK: - Icon Picker (minor visual tweaks)
struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    let icons = [
        "✨", "💧", "📚", "🏃‍♂️", "🧘‍♀️", "🏋️", "🍎", "😴",
        "🎸", "🎨", "✍️", "💻", "🪴", "💊", "🧹", "💰",
        "❤️", "🔥", "🚀", "💡", "🎯", "🏆", "🌟", "✅"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                        dismiss()
                    } label: {
                        Text(icon)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
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
                                            ? DesignTokens.accent
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
        .frame(width: 280, height: 200)
        .background(DesignTokens.background)
    }
}
