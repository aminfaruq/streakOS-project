import SwiftUI

/// Popover grid for choosing a habit icon.
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
