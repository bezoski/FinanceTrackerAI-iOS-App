import SwiftUI
import SwiftData
import Charts
import CoreML

struct CategorySummary: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
}

struct ComparisonData: Identifiable {
    let id = UUID()
    let type: String
    let amount: Double
    let color: Color
}

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @AppStorage("currencySymbol") private var currencySymbol: String = "PLN"
    @AppStorage("userName") private var userName: String = "User"

    @State private var aiInsightText: String = "Analyzing data..."
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showDatePicker = false
    
    var filteredTransactions: [Transaction] {
        transactions.filter {
            let comp = Calendar.current.dateComponents([.year, .month], from: $0.date)
            return comp.year == selectedYear && comp.month == selectedMonth
        }
    }
    
    var expenseData: [CategorySummary] {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        var dict: [String: Double] = [:]
        for txn in expenses {
            dict[txn.category, default: 0] += txn.amount
        }
        return dict.map { CategorySummary(name: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
    
    var incomeData: [CategorySummary] {
        let incomes = filteredTransactions.filter { $0.type == .income }
        var dict: [String: Double] = [:]
        for txn in incomes {
            dict[txn.paymentMethod, default: 0] += txn.amount
        }
        return dict.map { CategorySummary(name: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }
    
    var totalExpenses: Double {
        expenseData.reduce(0) { $0 + $1.total }
    }
    
    var totalIncome: Double {
        incomeData.reduce(0) { $0 + $1.total }
    }
    
    var monthlyNet: Double {
        totalIncome - totalExpenses
    }
    
    var comparisonChartData: [ComparisonData] {
        [
            ComparisonData(type: "Income", amount: totalIncome, color: .green),
            ComparisonData(type: "Expense", amount: totalExpenses, color: .red)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    Button {
                        showDatePicker = true
                    } label: {
                        HStack {
                            Text("\(Calendar.current.monthSymbols[selectedMonth - 1]) \(String(selectedYear))")
                                .font(.title2.bold())
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.title3)
                        }
                        .foregroundStyle(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.yellow)
                            Text("AI Insights")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        
                        Text(aiInsightText)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Spending by Category")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if expenseData.isEmpty {
                            Text("No expenses this month.")
                                .foregroundStyle(.gray)
                                .padding()
                        } else {
                            Chart(expenseData) { item in
                                SectorMark(
                                    angle: .value("Total", item.total),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("Category", item.name))
                                .annotation(position: .overlay) {
                                    Text(String(format: "%.0f%%", (item.total / totalExpenses) * 100))
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 250)
                            .padding()
                        }
                    }

                    if !expenseData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Top Expenses")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(expenseData) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("-\(String(format: "%.2f", item.total)) \(currencySymbol)")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.red)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                Divider().padding(.horizontal)
                            }
                        }
                    }

                    if !incomeData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Income Sources")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(incomeData) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("+\(String(format: "%.2f", item.total)) \(currencySymbol)")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.green)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                Divider().padding(.horizontal)
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Income vs Expense")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(comparisonChartData) { item in
                            BarMark(
                                x: .value("Type", item.type),
                                y: .value("Amount", item.amount)
                            )
                            .foregroundStyle(item.color)
                            .cornerRadius(8)
                            .annotation(position: .top) {
                                Text("\(String(format: "%.0f", item.amount)) \(currencySymbol)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }

                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Summary")
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    HStack {
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Year", selection: $selectedYear) {
                            let currentYear = Calendar.current.component(.year, from: Date())
                            ForEach((currentYear - 5)...(currentYear + 5), id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button("Done") {
                            showDatePicker = false
                        }
                    }
                }
                .presentationDetents([.height(300)])
            }
            .onAppear {
                runCoreMLPrediction()
            }
            .onChange(of: transactions) { _, _ in
                runCoreMLPrediction()
            }
            .onChange(of: currencySymbol) { _, _ in
                runCoreMLPrediction()
            }
            .onChange(of: selectedMonth) { _, _ in
                runCoreMLPrediction()
            }
            .onChange(of: selectedYear) { _, _ in
                runCoreMLPrediction()
            }
        }
    }

    private func runCoreMLPrediction() {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        let monthName = Calendar.current.monthSymbols[selectedMonth - 1]
        
        guard !filteredTransactions.isEmpty else {
            aiInsightText = "Hi \(userName)! Add some income or expenses in \(monthName) \(selectedYear) so I can analyze your finances."
            return
        }
        
        var methodDict: [String: Double] = [:]
        for txn in expenses {
            methodDict[txn.paymentMethod, default: 0] += txn.amount
        }
        let topMethod = methodDict.max { $0.value < $1.value }?.key ?? "Card"
        
        if let topCategory = expenseData.first {
            let percentage = (topCategory.total / totalExpenses) * 100
            
            aiInsightText = "Hi \(userName). In \(monthName) \(selectedYear), you earned \(String(format: "%.0f", totalIncome)) \(currencySymbol) and spent \(String(format: "%.0f", totalExpenses)) \(currencySymbol).\n\nYou spent \(String(format: "%.0f", percentage))% of your expenses on \(topCategory.name) mostly using \(topMethod). Your net cash flow is \(String(format: "%.2f", monthlyNet)) \(currencySymbol)."
        } else {
            aiInsightText = "Hi \(userName). You had a great month in \(monthName) \(selectedYear) with \(String(format: "%.0f", totalIncome)) \(currencySymbol) earned and no expenses recorded yet!"
        }
    }
}
