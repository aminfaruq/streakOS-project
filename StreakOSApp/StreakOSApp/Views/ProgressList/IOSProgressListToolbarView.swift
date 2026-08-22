import SwiftUI

/// Toolbar with edit toggle, date navigation and add button.
struct IOSProgressListToolbarView: View {
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
                        .font(.system(size: 15))
                    Text(isEditMode ? "Done" : "Edit")
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            isEditMode
                            ? IOSDesignTokens.accent.opacity(0.15)
                            : Color.gray.opacity(0.08)
                        )
                )
            }
            .buttonStyle(.plain)
            .foregroundStyle(isEditMode ? IOSDesignTokens.accent : .primary)
            
            Spacer()
            
            // Date Navigation
            HStack(spacing: 10) {
                Button(action: onBackward) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            canNavigateBackward
                            ? .primary
                            : .tertiary
                        )
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .disabled(!canNavigateBackward)
                
                if !isToday {
                    Button(action: onToday) {
                        Text("Today")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(IOSDesignTokens.accent)
                } else {
                    Text("Today")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                
                Button(action: onForward) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            canNavigateForward
                            ? .primary
                            : .tertiary
                        )
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .disabled(!canNavigateForward)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(IOSDesignTokens.card)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            
            Spacer()
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(IOSDesignTokens.accent)
                            .shadow(color: IOSDesignTokens.accent.opacity(0.3), radius: 3, x: 0, y: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
