import SwiftUI
import SwiftData

@main
struct FinanceTrackerAIApp: App {
    var body: some Scene {
        WindowGroup{
            MainTabView()
        }
        .modelContainer(for: [Transaction.self, CategoryItem.self])
    }
}
