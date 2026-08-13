import SwiftUI
import Combine
import StreakOSFramework

/// PRD §9.3 item card wrapper that functionally separates Count and Timer UI.
struct ItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool = false
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onToggleTimer: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        if progress.item.type == .minutes {
            TimerItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onToggleTimer: onToggleTimer,
                onTap: onTap
            )
        } else {
            CountItemCardView(
                progress: progress,
                isEditMode: isEditMode,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onTap: onTap
            )
        }
    }
}

// MARK: - Count UI
struct CountItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                tapContent
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)
                
                Spacer(minLength: 0)
                
                if isEditMode {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                        .frame(width: DesignTokens.buttonSize, height: DesignTokens.buttonSize)
                } else if progress.record?.isCompleted == true {
                    idempotentCircle
                } else {
                    plusButton
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(DesignTokens.accent)
                        .frame(width: max(0, geometry.size.width * progressFraction), height: 4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressFraction)
                }
            }
            .frame(height: 4)
        }
        .padding(20)
        .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isEditMode ? 0.98 : 1.0)
    }
    
    private var tapContent: some View {
        HStack(spacing: 16) {
            iconContainer
            
            VStack(alignment: .leading, spacing: 6) {
                Text(progress.item.name)
                    .font(.system(size: 19, weight: .bold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let record = progress.record, record.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DesignTokens.accent)
                        Text("Completed")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(DesignTokens.accent)
                    } else {
                        Text(progress.displayText)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
    }
    
    private var iconContainer: some View {
        Text(progress.item.icon)
            .font(.system(size: 26))
            .frame(width: 56, height: 56)
            .background(Color.gray.opacity(0.1), in: Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
    
    private var plusButton: some View {
        Button(action: onIncrement) {
            Text("+1")
                .font(.system(size: 16, weight: .bold))
                .frame(width: 48, height: 48)
                .foregroundStyle(.primary)
                .background(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color.gray.opacity(0.05)))
                )
        }
        .buttonStyle(.plain)
    }
    
    private var idempotentCircle: some View {
        Button(action: onDecrement) {
            Circle()
                .fill(DesignTokens.accent)
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
        .buttonStyle(.plain)
    }
    
    private var progressFraction: CGFloat {
        if progress.record?.isCompleted == true { return 1.0 }
        let current = CGFloat(progress.record?.currentCount ?? 0)
        let target = CGFloat(progress.item.targetCount)
        return min(current / target, 1.0)
    }
}

// MARK: - Timer UI
struct TimerItemCardView: View {
    let progress: ItemProgress
    var isEditMode: Bool
    let onToggleTimer: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    tapContent(liveNow: context.date)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: onTap)
                    
                    Spacer(minLength: 0)
                    
                    if isEditMode {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                            .frame(width: DesignTokens.buttonSize, height: DesignTokens.buttonSize)
                    } else {
                        timerButton
                    }
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(DesignTokens.accent)
                            .frame(width: max(0, geometry.size.width * progressFraction(liveNow: context.date)), height: 4)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressFraction(liveNow: context.date))
                    }
                }
                .frame(height: 4)
            }
            .padding(20)
            .background(DesignTokens.card, in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isEditMode ? 0.98 : 1.0)
        }
    }
    
    private func tapContent(liveNow: Date) -> some View {
        HStack(spacing: 16) {
            iconContainer
            
            VStack(alignment: .leading, spacing: 6) {
                Text(progress.item.name)
                    .font(.system(size: 19, weight: .bold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if let record = progress.record, record.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DesignTokens.accent)
                        Text("Completed")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(DesignTokens.accent)
                    }
                    Text(timerDisplayText(liveNow: liveNow))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(isTimerRunning ? DesignTokens.accent : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isTimerRunning ? DesignTokens.accent.opacity(0.1) : Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }
    
    private var iconContainer: some View {
        Text(progress.item.icon)
            .font(.system(size: 26))
            .frame(width: 56, height: 56)
            .background(Color.gray.opacity(0.1), in: Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
    
    private var timerButton: some View {
        Button(action: onToggleTimer) {
            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                .font(.system(size: 20))
                .frame(width: 48, height: 48)
                .foregroundStyle(isTimerRunning ? .white : DesignTokens.accent)
                .background(
                    Circle()
                        .fill(isTimerRunning ? DesignTokens.accent : DesignTokens.accent.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
    
    private func progressFraction(liveNow: Date) -> CGFloat {
        if progress.record?.isCompleted == true { return 1.0 }
        
        var current = CGFloat(progress.record?.currentCount ?? 0)
        if let start = progress.record?.timerStartDate {
            let elapsed = CGFloat(liveNow.timeIntervalSince(start))
            current += elapsed
        }
        
        let target = CGFloat(progress.item.targetCount * 60)
        return min(current / target, 1.0)
    }
    
    private var isTimerRunning: Bool {
        progress.record?.timerStartDate != nil
    }
    
    private func timerDisplayText(liveNow: Date) -> String {
        var currentSeconds = progress.record?.currentCount ?? 0
        if let start = progress.record?.timerStartDate {
            currentSeconds += Int(liveNow.timeIntervalSince(start))
        }
        
        let minutes = currentSeconds / 60
        let seconds = currentSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

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
