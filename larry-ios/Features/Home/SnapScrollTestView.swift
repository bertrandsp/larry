import SwiftUI

struct SnapScrollTestView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Larry - Daily Words")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Spacer()
                
                // Use the perfect snap scroll view
                PerfectSnapScrollView()
                
                Spacer()
            }
        }
    }
}

// Alternative test view using TabView approach
struct TabViewTestView: View {
    var body: some View {
        TabViewSnapScroll()
    }
}

// Test view for UIKit implementation
struct UIKitTestView: View {
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Larry")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1)")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                HighPerformanceSnapScrollView(currentIndex: $currentIndex)
            }
        }
    }
}

#Preview("Perfect Snap Scroll") {
    SnapScrollTestView()
}

#Preview("TabView Approach") {
    TabViewTestView()
}

#Preview("UIKit Implementation") {
    UIKitTestView()
}
