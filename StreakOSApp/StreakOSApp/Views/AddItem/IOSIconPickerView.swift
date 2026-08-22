import SwiftUI

/// Sheet grid for choosing a habit icon.
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
