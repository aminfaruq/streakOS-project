import Foundation

public enum ItemNameGenerator {
    
    public static func isNameUnique(
        _ name: String,
        among items: [Item],
        excluding itemId: UUID? = nil
    ) -> Bool {
        let lowercasedName = name.lowercased()
        return !items.contains { item in
            item.id != itemId && item.name.lowercased() == lowercasedName
        }
    }
    
    public static func duplicateName(
        for originalName: String,
        among items: [Item]
    ) -> String {
        let baseName = strippingTrailingNumber(from: originalName)
        var counter = 2
        let existingNames = Set(items.map { $0.name.lowercased() })
        
        while true {
            let candidate = "\(baseName) \(counter)"
            if !existingNames.contains(candidate.lowercased()) {
                return candidate
            }
            counter += 1
        }
    }
    
    private static func strippingTrailingNumber(from name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2, Int(components.last ?? "") != nil {
            return components.dropLast().joined(separator: " ")
        }
        return name
    }
}
