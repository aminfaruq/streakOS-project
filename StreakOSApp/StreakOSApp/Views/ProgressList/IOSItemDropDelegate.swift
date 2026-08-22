import SwiftUI
import StreakOSFramework

struct IOSItemDropDelegate: DropDelegate {
    let item: ItemProgress
    @Binding var items: [ItemProgress]
    @Binding var draggedItem: ItemProgress?
    let onMove: (Int, Int) -> Void
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.item.id != item.item.id,
              let from = items.firstIndex(where: { $0.item.id == draggedItem.item.id }),
              let to = items.firstIndex(where: { $0.item.id == item.item.id }) else {
            return
        }
        
        if items[to].item.id != draggedItem.item.id {
            withAnimation {
                onMove(from, to)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
