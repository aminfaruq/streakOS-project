import SwiftUI

/// Reusable section card wrapper for the Add Item form.
struct IOSAddItemSectionCard<Content: View>: View {
    let icon: String
    let title: String
    let description: String
    let content: Content

    init(
        icon: String,
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.content = content()
    }

    var body: some View {
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
            content
        }
    }
}
