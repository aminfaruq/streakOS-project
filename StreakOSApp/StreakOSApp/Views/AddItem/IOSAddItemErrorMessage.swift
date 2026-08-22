import SwiftUI

/// Inline validation error shown at the bottom of the Add Item form.
struct IOSAddItemErrorMessage: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline)
            Text(message)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.red)
        .padding(.top, 4)
    }
}
