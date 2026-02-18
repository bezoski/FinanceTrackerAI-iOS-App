import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var transaction: Transaction
    
    @Query(sort: \CategoryItem.name) var availableCategories: [CategoryItem]
    @AppStorage("currencySymbol") private var currencySymbol: String = "PLN"

    @State private var title = ""
    @State private var amount = 0.0
    @State private var type: TransactionType = .expense
    @State private var date = Date()
    @State private var selectedCategoryName: String = "Other"
    @State private var paymentMethod: String = "Card"
    
    let incomeMethods = ["Cash", "Bank Account"]
    let expenseMethods = ["Cash", "Card"]

    var body: some View {
        Form {
            Section("Details") {
                TextField("Description", text: $title)
                
                HStack {
                    TextField("Amount", value: $amount, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad)
                    Text(currencySymbol)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
                
                Picker("Type", selection: $type) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .onChange(of: type) { oldValue, newValue in
                    if newValue == .income {
                        paymentMethod = "Bank Account"
                    } else {
                        paymentMethod = "Card"
                    }
                }
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                Picker("Payment Method", selection: $paymentMethod) {
                    let methods = type == .income ? incomeMethods : expenseMethods
                    ForEach(methods, id: \.self) { method in
                        Text(method).tag(method)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if type == .expense {
                Section("Category") {
                    if availableCategories.isEmpty {
                        Text("Please add categories in Settings")
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else {
                        Picker("Select Category", selection: $selectedCategoryName) {
                            Text("Other").tag("Other")
                            ForEach(availableCategories) { category in
                                Text(category.name).tag(category.name)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
        }
        .navigationTitle("Edit Transaction")
        .toolbar {
            Button("Save") {
                transaction.title = title
                transaction.amount = amount
                transaction.type = type
                transaction.date = date
                transaction.paymentMethod = paymentMethod
                transaction.category = (type == .expense) ? selectedCategoryName : "Budget Income"
                dismiss()
            }
        }
        .onAppear {
            title = transaction.title
            amount = transaction.amount
            type = transaction.type
            date = transaction.date
            paymentMethod = transaction.paymentMethod
            if transaction.type == .expense {
                selectedCategoryName = transaction.category
            } else {
                if let firstCategory = availableCategories.first {
                    selectedCategoryName = firstCategory.name
                }
            }
        }
    }
}
