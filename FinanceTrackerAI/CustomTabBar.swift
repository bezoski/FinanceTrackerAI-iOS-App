import SwiftUI

enum Tab{
    case home
    case summary
}
struct CustomTabBar: View {
    @Binding var currentTab: Tab
    var onAddTap: () -> Void
    
    let barHeight: CGFloat = 60
    let buttonSize: CGFloat = 64
    let buttonOffset: CGFloat = -15
    
    var body: some View {
        ZStack(alignment: .bottom){
            HStack{
                Button { currentTab = .home} label: {
                    VStack(spacing: 4) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                        Text("Home").font(.system(size: 11))
                    }
                    .foregroundStyle(currentTab == .home ? .black : .gray)
                }
                .frame(maxWidth: .infinity)
                
                Spacer().frame(width: buttonSize)
                
                Button { currentTab = .summary } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                        Text("Summary").font(.system(size: 11))
                    }
                    .foregroundStyle(currentTab == .summary ? .black : .gray)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: barHeight)
            .background(.white)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
            
            Button { onAddTap() } label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color(red: 0.1, green: 0.7, blue: 0.3))
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    Image(systemName: "plus")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .offset(y: buttonOffset)
        }
        .padding(.horizontal)
    }
}
