import SwiftUI
import AppKit

/// PRD §9.8 design tokens, adaptive for light + dark.
enum DesignTokens {
    static let background = Color(
        light: Color(red: 0xF5 / 255, green: 0xF5 / 255, blue: 0xF7 / 255),
        dark: Color(red: 0x09 / 255, green: 0x09 / 255, blue: 0x0b / 255)
    )
    static let card = Color(
        light: Color.white,
        dark: Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1E / 255)
    )
    static let accent = Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x59 / 255)
    
    static let cardRadius: CGFloat = 20
    static let buttonSize: CGFloat = 46
    static let iconContainerSize: CGFloat = 56
}

extension Color {
    init(light: Color, dark: Color) {
        let ns = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        }
        self.init(nsColor: ns)
    }
}
