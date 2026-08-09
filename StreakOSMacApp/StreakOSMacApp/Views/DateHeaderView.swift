import SwiftUI

/// PRD §9.5 date header with backward/forward navigation.
struct DateHeaderView: View {
    let title: String
    let isToday: Bool
    let canGoBackward: Bool
    let canGoForward: Bool
    let onBackward: () -> Void
    let onForward: () -> Void
    let onToday: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBackward) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!canGoBackward)

                Spacer()

                Text(title)
                    .font(.system(.title3, design: .default).weight(.semibold))

                Spacer()

                Button(action: onForward) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!canGoForward)
            }

            if !isToday {
                Button("Today", action: onToday)
                    .font(.subheadline)
                    .buttonStyle(.link)
            }
        }
        .padding(.horizontal, 4)
    }
}