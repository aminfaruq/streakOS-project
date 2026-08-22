import SwiftUI

/// Empty state shown when there are no habits for the selected date.
struct ProgressListEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("No habits yet")
                .font(.title3.weight(.semibold))
            Text("Add your first habit to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
}
