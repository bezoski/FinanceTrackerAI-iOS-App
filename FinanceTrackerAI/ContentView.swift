import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var categories: [CategoryItem]
    
    @AppStorage("currencySymbol") private var currencySymbol: String = "PLN"
    @AppStorage("userName") private var userName: String = "User"
    @AppStorage("didSetupData") private var didSetupData: Bool = false
    
    @State private var selectedType: TransactionType = .expense
    @State private var showSettings = false

    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var currentBalance: Double {
        totalIncome - totalExpense
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    Text("\(String(format: "%.2f", currentBalance)) \(currencySymbol)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(currentBalance >= 0 ? Color.primary : Color.red)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("Income")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text("+\(String(format: "%.2f", totalIncome))")
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        VStack {
                            Text("Spent")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text("-\(String(format: "%.2f", totalExpense))")
                                .font(.headline)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 15)

                Picker("Type", selection: $selectedType) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)

                List {
                    ForEach(transactions.filter { $0.type == selectedType }) { transaction in
                        NavigationLink {
                            EditTransactionView(transaction: transaction)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(transaction.title)
                                        .font(.headline)
                                    HStack {
                                        Text(transaction.category)
                                        Text("•")
                                        Text(transaction.paymentMethod)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(String(format: "%.2f", transaction.amount)) \(currencySymbol)")
                                    .fontWeight(.bold)
                                    .foregroundStyle(transaction.type == .expense ? Color.red : Color.green)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Hi, \(userName)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                if !didSetupData {
                    let defaults = [
                        CategoryItem(name: "Food"),
                        CategoryItem(name: "Subscriptions"),
                        CategoryItem(name: "Entertainment"),
                        CategoryItem(name: "Shopping"),
                        CategoryItem(name: "Transport")
                    ]
                    for cat in defaults {
                        modelContext.insert(cat)
                    }
                    didSetupData = true
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let filtered = transactions.filter { $0.type == selectedType }
            for index in offsets {
                let itemToDelete = filtered[index]
                modelContext.delete(itemToDelete)
            }
        }
    }
}
