import SwiftUI
import StreakOSFramework
import StreakOSPresentation

struct IOSDateHeaderView: View {
    let date: Date
    let items: [ItemProgress]
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.wide)))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(date.formatted(.dateTime.day().month().year()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: globalProgress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: globalProgress)
                
                Text("\(Int(globalProgress * 100))%")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(globalProgress == 1.0 ? Color.blue : .primary)
            }
            .frame(width: 44, height: 44)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var globalProgress: CGFloat {
        guard !items.isEmpty else { return 0 }
        
        let total = CGFloat(items.count)
        let completed = items.reduce(0.0) { sum, progress in
            if progress.record?.isCompleted == true {
                return sum + 1.0
            }
            
            var current = CGFloat(progress.record?.currentCount ?? 0)
            if let start = progress.record?.timerStartDate {
                let elapsed = CGFloat(Date().timeIntervalSince(start))
                current += elapsed
            }
            
            let target = CGFloat(progress.item.type == .minutes ? progress.item.targetCount * 60 : progress.item.targetCount)
            return sum + min(current / target, 1.0)
        }
        
        return completed / total
    }
}
