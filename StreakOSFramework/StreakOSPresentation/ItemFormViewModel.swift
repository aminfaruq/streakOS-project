import Foundation
import Combine
import StreakOSFramework

@MainActor
public final class ItemFormViewModel: ObservableObject {
    @Published public var name = ""
    @Published public var icon = "📋"
    @Published public var targetCount = 1
    @Published public var startDate = Date()
    @Published public var endDate: Date?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isSaving = false
    
    public var isEditing: Bool { existingItem != nil }
    
    public var canSave: Bool {
        isNameValid && isIconValid && isTargetValid && dateRangeValid
    }
    
    private let creator: (any ItemCreator)?
    private let updater: (any ItemUpdater)?
    private let existingItem: Item?
    private let onSaved: (Item) -> Void
    
    public init(
        creator: any ItemCreator,
        onCreated: @escaping (Item) -> Void
    ) {
        self.creator = creator
        self.updater = nil
        self.existingItem = nil
        self.onSaved = onCreated
    }
    
    public init(
        updater: any ItemUpdater,
        item: Item,
        onUpdated: @escaping (Item) -> Void
    ) {
        self.creator = nil
        self.updater = updater
        self.existingItem = item
        self.onSaved = onUpdated
        self.name = item.name
        self.icon = item.icon
        self.targetCount = item.targetCount
        self.startDate = item.startDate
        self.endDate = item.endDate
    }
    
    public func save() {
        errorMessage = nil
        guard canSave else {
            errorMessage = "Please fill in the required fields"
            return
        }
        
        isSaving = true
        if isEditing {
            saveUpdated()
        } else {
            saveNew()
        }
    }
    
    private func saveNew() {
        guard let creator else { return }
        creator.create(
            name: name,
            icon: icon,
            targetCount: targetCount,
            startDate: startDate,
            endDate: endDate
        ) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func saveUpdated() {
        guard let updater, let existingItem else { return }
        updater.update(
            Item(
                id: existingItem.id,
                name: name,
                icon: icon,
                targetCount: targetCount,
                startDate: startDate,
                endDate: endDate,
                displayOrder: existingItem.displayOrder,
                createdAt: existingItem.createdAt,
                updatedAt: existingItem.updatedAt
            )
        ) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: Swift.Result<Item, any Error>) {
        switch result {
        case let .success(item):
            onSaved(item)
            errorMessage = nil
        case .failure:
            errorMessage = nameDuplicateMessage
        }
        isSaving = false
    }
    
    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count <= 100
    }
    
    private var isIconValid: Bool {
        icon.count == 1
    }
    
    private var isTargetValid: Bool {
        (1...999).contains(targetCount)
    }
    
    private var dateRangeValid: Bool {
        guard let endDate else { return true }
        return endDate >= startDate
    }
    
    private var nameDuplicateMessage: String {
        "An item with this name already exists."
    }
}
