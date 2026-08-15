import SwiftUI
import StreakOSFramework
import StreakOSPresentation

struct MenuBarProgressView: View {
    @ObservedObject var viewModel: ProgressFeedViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("StreakOS")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                let completedCount = viewModel.progressItems.filter { $0.record?.isCompleted == true }.count
                let total = viewModel.progressItems.count
                
                Text("\(completedCount)/\(total)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(completedCount == total && total > 0 ? .white : .secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                completedCount == total && total > 0
                                    ? DesignTokens.accent
                                    : Color.gray.opacity(0.1)
                            )
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // MARK: - Content
            ScrollView {
                LazyVStack(spacing: 10) {
                    if viewModel.progressItems.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 28))
                                .foregroundStyle(.tertiary)
                            Text("No habits for today.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 30)
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
            
            // MARK: - Footer
            Button(action: {
                openWindow(id: "main")
            }) {
                HStack {
                    Image(systemName: "macwindow")
                        .font(.system(size: 12, weight: .medium))
                    Text("Open StreakOS")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignTokens.accent.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DesignTokens.accent.opacity(0.3), lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
        VStack(spacing: 8) {
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
            
            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 3)
                    
                    Capsule()
                        .fill(progress.progressFraction >= 1.0 ? DesignTokens.accent : DesignTokens.accent.opacity(0.8))
                        .frame(width: max(0, geometry.size.width * CGFloat(progress.progressFraction)), height: 3)
                        .animation(.easeInOut(duration: 0.3), value: progress.progressFraction)
                }
            }
            .frame(height: 3)
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
    
    // MARK: - Count Adjuster
    @ViewBuilder
    private func countAdjuster() -> some View {
        HStack(spacing: 8) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 24, height: 24)
                    .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            
            Text(progress.displayText)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(progress.progressFraction >= 1.0 ? DesignTokens.accent : .primary)
                .frame(minWidth: 44, alignment: .center)
                
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(DesignTokens.accent)
                    .frame(width: 24, height: 24)
                    .background(DesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Timer Adjuster
    @ViewBuilder
    private func minutesAdjuster(liveNow: Date) -> some View {
        let isRunning = (progress.record?.timerStartDate != nil)
        
        HStack(spacing: 8) {
            if !isRunning {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 24, height: 24)
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            }
            
            Button(action: onToggleTimer) {
                HStack(spacing: 4) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 10))
                    Text(timerDisplayText(liveNow: liveNow))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(isRunning ? DesignTokens.accent : .primary)
                .frame(minWidth: 58, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(isRunning ? DesignTokens.accent.opacity(0.15) : Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            
            if !isRunning {
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(DesignTokens.accent)
                        .frame(width: 24, height: 24)
                        .background(DesignTokens.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
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
