import SwiftUI

struct MainTabView: View {
    @State private var currentTab: Tab = .home
    @State private var showAddSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom){
            Group{
                if currentTab == .home{
                    ContentView()
                } else {
                    SummaryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(currentTab: $currentTab, onAddTap: {
                showAddSheet = true
            })
        }
        .sheet(isPresented: $showAddSheet){
            AddTransactionView()
        }
    }
}
