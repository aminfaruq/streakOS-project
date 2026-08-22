import SwiftUI

struct IOSItemActionsActionListView: View {
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            actionButton(title: "Edit Item", icon: "pencil", action: onEdit)
            actionButton(title: "Duplicate", icon: "doc.on.doc", action: onDuplicate)
            actionButton(title: "Delete", icon: "trash", color: .red, action: onDelete)
        }
        .padding()
    }

    private func actionButton(title: String, icon: String, color: Color = .primary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.body.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.001)) // making it tappable everywhere
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(color)
    }
}
