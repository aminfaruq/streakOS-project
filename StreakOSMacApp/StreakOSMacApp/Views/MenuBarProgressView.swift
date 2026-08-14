import SwiftUI
import StreakOSFramework
import StreakOSPresentation

struct MenuBarProgressView: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("StreakOS")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                
                let completedCount = viewModel.progressItems.filter { $0.record?.isCompleted == true }.count
                Text("\(completedCount)/\(viewModel.progressItems.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1), in: Capsule())
            }
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.progressItems.isEmpty {
                        Text("No habits for today.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                    } else {
                        ForEach(viewModel.progressItems, id: \.item.id) { progress in
                            MenuBarItemRow(
                                progress: progress,
                                onIncrement: { viewModel.increment(progress, on: Date()) },
                                onDecrement: { viewModel.decrement(progress, on: Date()) },
                                onToggleTimer: { viewModel.toggleTimer(for: progress, on: Date()) }
                            )
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 350)
            
            Divider()
            
            // Footer
            Button(action: {
                openWindow(id: "main")
            }) {
                HStack {
                    Image(systemName: "macwindow")
                    Text("Open StreakOS")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(DesignTokens.card)
        }
        .frame(width: 320)
        .background(DesignTokens.background)
        .onAppear {
            viewModel.load(for: Date())
        }
    }
    

}

struct MenuBarItemRow: View {
    let progress: ItemProgress
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(progress.item.icon)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            
            Text(progress.item.name)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            
            Spacer()
            
            if progress.item.type == .minutes {
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    minutesAdjuster(liveNow: context.date)
                }
            } else {
                countAdjuster()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(isHovering ? 0.08 : 0.03), radius: isHovering ? 4 : 2, x: 0, y: isHovering ? 2 : 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
    
    @ViewBuilder
    private func countAdjuster() -> some View {
        HStack(spacing: 8) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 20, height: 20)
                    .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            
            Text(progress.displayText)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(progress.progressFraction >= 1.0 ? DesignTokens.accent : .primary)
                .frame(minWidth: 40, alignment: .center)
                
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DesignTokens.accent)
                    .frame(width: 20, height: 20)
                    .background(DesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func minutesAdjuster(liveNow: Date) -> some View {
        let isRunning = (progress.record?.timerStartDate != nil)
        
        HStack(spacing: 8) {
            if !isRunning {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 20, height: 20)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            
            Button(action: onToggleTimer) {
                HStack(spacing: 4) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 10))
                    Text(timerDisplayText(liveNow: liveNow))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(isRunning ? DesignTokens.accent : .primary)
                .frame(minWidth: 54, alignment: .center)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(isRunning ? DesignTokens.accent.opacity(0.15) : Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            
            if !isRunning {
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(DesignTokens.accent)
                        .frame(width: 20, height: 20)
                        .background(DesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func timerDisplayText(liveNow: Date) -> String {
        guard let record = progress.record else {
            return "0:00"
        }
        
        let elapsed = record.timerStartDate != nil ? Int(liveNow.timeIntervalSince(record.timerStartDate!)) : 0
        let totalSeconds = record.currentCount + elapsed
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
