import SwiftUI
import AppKit

enum DesignTokens {
    static let accent = Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
    static let cardRadius: CGFloat = 12
    static let smallRadius: CGFloat = 8
    static let buttonSize: CGFloat = 32
    static let iconContainerSize: CGFloat = 40
    
    static var background: Color {
        Color(NSColor.windowBackgroundColor)
    }
    
    static var card: Color {
        Color(NSColor.controlBackgroundColor)
    }
}
