import SwiftUI

/// Toolbar with edit toggle, date navigation and add button.
struct ProgressListToolbarView: View {
    @Binding var isEditMode: Bool
    let canNavigateBackward: Bool
    let canNavigateForward: Bool
    let isToday: Bool
    let onBackward: () -> Void
    let onForward: () -> Void
    let onToday: () -> Void
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { withAnimation { isEditMode.toggle() } }) {
                HStack(spacing: 6) {
                    Image(systemName: isEditMode ? "checkmark.circle.fill" : "pencil")
                        .font(.system(size: 14))
                    Text(isEditMode ? "Done" : "Edit")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isEditMode ? DesignTokens.accent.opacity(0.1) : Color.gray.opacity(0.08))
                )
            }
            .buttonStyle(.borderless)
            .foregroundStyle(isEditMode ? DesignTokens.accent : .primary)
            
            Spacer()
            
            // Date Navigation
            HStack(spacing: 8) {
                Button(action: onBackward) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.borderless)
                .disabled(!canNavigateBackward)
                
                if !isToday {
                    Button(action: onToday) {
                        Text("Today")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(DesignTokens.accent)
                } else {
                    Text("Today")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                Button(action: onForward) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.borderless)
                .disabled(!canNavigateForward)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignTokens.card)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.accent)
            .clipShape(Circle())
            .shadow(color: DesignTokens.accent.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
