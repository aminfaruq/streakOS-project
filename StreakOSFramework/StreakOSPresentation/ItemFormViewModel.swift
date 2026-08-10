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

    public var canSave: Bool {
        isNameValid && isIconValid && isTargetValid && dateRangeValid
    }

    private let creator: any ItemCreator
    private let onCreated: (Item) -> Void

    public init(
        creator: any ItemCreator,
        onCreated: @escaping (Item) -> Void
    ) {
        self.creator = creator
        self.onCreated = onCreated
    }

    public func save() {
        errorMessage = nil
        guard canSave else {
            errorMessage = "Please fill in the required fields"
            return
        }

        isSaving = true
        creator.create(
            name: name,
            icon: icon,
            targetCount: targetCount,
            startDate: startDate,
            endDate: endDate
        ) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(item):
                onCreated(item)
            case .failure:
                errorMessage = nameDuplicateMessage
            }
            isSaving = false
        }
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