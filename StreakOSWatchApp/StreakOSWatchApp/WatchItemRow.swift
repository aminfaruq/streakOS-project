import SwiftUI
import StreakOSFramework
import StreakOSPresentation

struct WatchItemRow: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    
    var body: some View {
        Button(action: {
            if progress.item.type == .count {
                onIncrement()
            } else {
                onToggleTimer()
            }
        }) {
            HStack(spacing: 8) {
                // Icon
                Text(progress.item.icon)
                    .font(.title2)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1), in: Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(progress.item.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if progress.item.type == .minutes {
                        let isRunning = (progress.record?.timerStartDate != nil)
                        HStack(spacing: 4) {
                            if isRunning {
                                Image(systemName: "timer")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.green)
                            }
                            
                            if isRunning, let startDate = progress.record?.timerStartDate, let currentCount = progress.record?.currentCount {
                                let conceptualStart = startDate.addingTimeInterval(-TimeInterval(currentCount))
                                Text(conceptualStart, style: .timer)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.green)
                            } else {
                                Text(progress.displayText)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(progress.progressFraction >= 1.0 ? .green : .secondary)
                            }
                        }
                    } else {
                        Text(progress.displayText)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(progress.progressFraction >= 1.0 ? .green : .secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain) // Use plain to prevent standard List button coloring
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDecrement()
            } label: {
                Label("Minus", systemImage: "minus.circle")
            }
            .tint(.orange)
        }
    }
}
