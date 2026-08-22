import SwiftUI

/// Header with app title, subtitle and daily completion ring.
struct IOSProgressListHeaderView: View {
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
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .tracking(-0.5)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(
                        IOSDesignTokens.accent,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progressFraction)
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 48)
            .opacity(isEditMode ? 0.3 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}
