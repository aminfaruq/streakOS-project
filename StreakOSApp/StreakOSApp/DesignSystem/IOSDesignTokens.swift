import SwiftUI
import UIKit

/// PRD §9.8 design tokens, adaptive for light + dark.
enum IOSDesignTokens {
    static let accent = Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
    
    // Dark mode Mac-like colors
    static let background = Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1E / 255) // #1C1C1E
    static let card = Color(red: 0x2A / 255, green: 0x2A / 255, blue: 0x2C / 255)       // #2A2A2C
    
    static let cardRadius: CGFloat = 20
    static let buttonSize: CGFloat = 46
    static let iconContainerSize: CGFloat = 56
}
