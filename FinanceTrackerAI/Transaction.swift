import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case income = "Income"
    case expense = "Expense"
}

@Model
class Transaction {
    var title: String
    var amount: Double
    var date: Date
    var type: TransactionType
    var category: String
    var paymentMethod: String
    
    init(title: String, amount: Double, date: Date, type: TransactionType, category: String, paymentMethod: String) {
        self.title = title
        self.amount = amount
        self.date = date
        self.type = type
        self.category = category
        self.paymentMethod = paymentMethod
    }
}
