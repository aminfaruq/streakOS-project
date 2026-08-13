import SwiftUI
import StreakOSFramework

/// PRD §4.4 action sheet equivalent (Mac) — Edit / Duplicate / Delete.
struct ItemActionsView: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    let onRestart: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            
            adjuster
            Divider()
            
            actions
        }
        .frame(width: 280)
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Text(progress.item.icon)
                .font(.system(size: 28))
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.1), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(progress.item.name)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                Text(progress.item.type == .minutes ? "Timer Options" : "Options & Progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    private var adjuster: some View {
        VStack(spacing: 12) {
            Text("ADJUST")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if progress.item.type == .count {
                HStack {
                    Button(action: onDecrement) {
                        Image(systemName: "minus")
                            .font(.title3.weight(.bold))
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(progress.displayText)
                        .font(.system(size: 20, weight: .bold))
                        .frame(minWidth: 80, alignment: .center)
                    
                    Spacer()
                    
                    Button(action: onIncrement) {
                        Image(systemName: "plus")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(DesignTokens.accent)
                            .frame(width: 44, height: 44)
                            .background(DesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            }
            
            let isRestartDisabled = (progress.record?.currentCount ?? 0) == 0 && progress.record?.timerStartDate == nil
            
            Button(action: onRestart) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Restart Progress")
                }
                .font(.body.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(isRestartDisabled ? Color.gray.opacity(0.1) : Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(isRestartDisabled ? Color.gray.opacity(0.5) : .orange)
            }
            .buttonStyle(.plain)
            .disabled(isRestartDisabled)
        }
        .padding()
    }
    
    private var actions: some View {
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
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(color)
    }
}
