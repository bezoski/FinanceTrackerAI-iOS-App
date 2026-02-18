import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("currencySymbol") private var currencySymbol: String = "PLN"
    
    @Query private var transactions: [Transaction]
    @Query(sort: \CategoryItem.name) private var categories: [CategoryItem]
    
    @State private var newCategoryName = ""
    @State private var showAddAlert = false
    
    @State private var categoryToEdit: CategoryItem?
    @State private var renameText = ""
    
    let exchangeRates: [String: Double] = [
        "PLN": 1.0,
        "USD": 4.0,
        "EUR": 4.3,
        "GBP": 5.2
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $userName)
                }
                
                Section("Currency (Auto-convert)") {
                    Picker("Select Currency", selection: $currencySymbol) {
                        Text("PLN (zł)").tag("PLN")
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("GBP (£)").tag("GBP")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: currencySymbol) { oldValue, newValue in
                        convertCurrency(from: oldValue, to: newValue)
                    }
                }
                
                Section("Categories (Tap to Rename)") {
                    ForEach(categories) { category in
                        Text(category.name)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                categoryToEdit = category
                                renameText = category.name
                            }
                    }
                    .onDelete(perform: deleteCategory)
                    
                    Button("Add New Category") {
                        showAddAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") { dismiss() }
            }
            .alert("New Category", isPresented: $showAddAlert) {
                TextField("Name", text: $newCategoryName)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    addCategory()
                }
            }
            .alert("Rename Category", isPresented: Binding(
                get: { categoryToEdit != nil },
                set: { if !$0 { categoryToEdit = nil } }
            )) {
                TextField("New Name", text: $renameText)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if let category = categoryToEdit {
                        category.name = renameText
                    }
                }
            }
        }
    }
    
    func convertCurrency(from oldCurr: String, to newCurr: String) {
        guard let oldRate = exchangeRates[oldCurr],
              let newRate = exchangeRates[newCurr] else { return }
        
        let ratio = oldRate / newRate
        
        for transaction in transactions {
            transaction.amount = transaction.amount * ratio
        }
    }
    
    func addCategory() {
        let newCat = CategoryItem(name: newCategoryName)
        modelContext.insert(newCat)
        newCategoryName = ""
    }
    
    func deleteCategory(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
}
