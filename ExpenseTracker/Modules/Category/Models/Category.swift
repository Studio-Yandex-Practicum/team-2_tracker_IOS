import Foundation

struct CategoryET {
    let id: UUID
    let name: String
    let icon: Asset.Icon.RawValue
    let expenses: [Expense]
}


