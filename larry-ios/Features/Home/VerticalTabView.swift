import SwiftUI

struct VerticalTabView<Content: View>: View {
    let content: () -> Content
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        content()
                    }
                }
                .scrollDisabled(true) // Completely disable native scrolling
                .onAppear {
                    // Scroll to the current index on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(currentIndex, anchor: .top)
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            // Prevent multiple simultaneous animations
                            guard !isAnimating else { return }
                            
                            let translation = value.translation.height
                            let velocity = value.velocity.height
                            
                            // More generous thresholds for better responsiveness
                            let distanceThreshold: CGFloat = screenHeight * 0.12 // 12% of screen height
                            let velocityThreshold: CGFloat = 400
                            
                            var targetIndex = currentIndex
                            
                            if translation > distanceThreshold || velocity > velocityThreshold {
                                // Swipe down - go to previous card
                                targetIndex = max(currentIndex - 1, 0)
                            } else if translation < -distanceThreshold || velocity < -velocityThreshold {
                                // Swipe up - go to next card
                                targetIndex = currentIndex + 1
                            }
                            
                            // Only animate if we're actually changing cards
                            if targetIndex != currentIndex {
                                isAnimating = true
                                currentIndex = targetIndex
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    proxy.scrollTo(currentIndex, anchor: .top)
                                } completion: {
                                    // Reset animation flag after animation completes
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isAnimating = false
                                    }
                                }
                            }
                        }
                )
            }
        }
    }
}

struct VerticalTabView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalTabView {
            ForEach(0..<3) { index in
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: UIScreen.main.bounds.height)
                    .overlay(
                        Text("Card \(index + 1)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                    .id(index)
            }
        }
    }
}