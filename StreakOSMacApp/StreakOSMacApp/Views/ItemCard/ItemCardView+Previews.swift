import SwiftUI
import StreakOSFramework

// MARK: - Previews
#Preview {
    ItemCardView(
        progress: ItemProgress(
            item: Item(id: UUID(), name: "Push Ups", icon: "💪", type: .count, targetCount: 10, startDate: .snapshot, endDate: nil, displayOrder: 0, createdAt: .snapshot, updatedAt: .snapshot),
            record: nil
        ),
        onIncrement: {},
        onDecrement: {},
        onToggleTimer: {},
        onTap: {}
    )
    .padding()
}

private extension Date {
    static var snapshot: Date { Date(timeIntervalSince1970: 1_700_000_000) }
}
