import SwiftUI
import UIKit

/// PRD §9.8 design tokens, adaptive for light + dark.
enum IOSDesignTokens {
    static let background = Color(UIColor.systemGroupedBackground)
    static let card = Color(UIColor.secondarySystemGroupedBackground)
    static let accent = Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
    
    static let cardRadius: CGFloat = 20
    static let buttonSize: CGFloat = 46
    static let iconContainerSize: CGFloat = 56
}
