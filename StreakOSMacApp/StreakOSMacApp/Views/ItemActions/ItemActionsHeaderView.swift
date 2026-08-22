import SwiftUI
import StreakOSFramework

struct ItemActionsHeaderView: View {
    let progress: ItemProgress

    var body: some View {
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
}
