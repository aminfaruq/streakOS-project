import SwiftUI

/// Header with app title, subtitle and daily completion ring.
struct ProgressListHeaderView: View {
    let title: String
    let completedCount: Int
    let totalCount: Int
    let isEditMode: Bool
    
    private var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("StreakOS")
                    .font(.system(size: 28, weight: .bold))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 3.5)
                
                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(DesignTokens.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progressFraction)
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 44, height: 44)
            .opacity(isEditMode ? 0.3 : 1.0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 18)
    }
}
