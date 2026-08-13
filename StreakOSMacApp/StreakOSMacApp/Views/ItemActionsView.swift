import SwiftUI
import StreakOSFramework

/// PRD §4.4 action sheet equivalent (Mac) — Edit / Duplicate / Delete.
struct ItemActionsView: View {
    let progress: ItemProgress
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(progress.item.icon)
                    .font(.system(size: 22))
                Text(progress.item.name)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
            }

            Divider()

            Button { onEdit() } label: { Label("Edit Item", systemImage: "pencil") }
            Button { onDuplicate() } label: { Label("Duplicate", systemImage: "doc.on.doc") }
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }

            Divider()

            Button("Done", action: onCancel)
                .buttonStyle(.plain)
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .frame(width: 260)
    }
}