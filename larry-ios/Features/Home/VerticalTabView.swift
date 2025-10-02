import SwiftUI

enum ScrollMode {
    case snapToPage    // Fast snapping between cards
    case continuous    // Slow continuous scrolling
}

struct VerticalTabView<Content: View>: View {
    let content: () -> Content
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var scrollMode: ScrollMode = .snapToPage
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            VStack(spacing: 0) {
                // Scroll mode toggle
                HStack {
                    Spacer()
                    Picker("Scroll Mode", selection: $scrollMode) {
                        Text("Snap").tag(ScrollMode.snapToPage)
                        Text("Scroll").tag(ScrollMode.continuous)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            content()
                        }
                    }
                    .scrollDisabled(scrollMode == .snapToPage) // Disable native scrolling only in snap mode
                    .onAppear {
                        // Scroll to the current index on appear
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if scrollMode == .snapToPage {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(currentIndex, anchor: .top)
                                }
                            }
                        }
                    }
                    .onChange(of: scrollMode) { _, newMode in
                        if newMode == .snapToPage {
                            // Switch to snap mode - scroll to current index
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(currentIndex, anchor: .top)
                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: scrollMode == .snapToPage ? 10 : 0)
                            .onEnded { value in
                                if scrollMode == .snapToPage {
                                    handleSnapGesture(value: value, screenHeight: screenHeight) {
                                        proxy.scrollTo($0, anchor: .top)
                                    }
                                }
                            }
                    )
                }
            }
        }
    }
    
    private func handleSnapGesture(value: DragGesture.Value, screenHeight: CGFloat, scrollTo: @escaping (Int) -> Void) {
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
                scrollTo(currentIndex)
            } completion: {
                // Reset animation flag after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimating = false
                }
            }
        }
    }
}

struct VerticalTabView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalTabView {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill([Color.blue, Color.green, Color.orange, Color.purple, Color.red][index])
                    .frame(height: UIScreen.main.bounds.height)
                    .overlay(
                        VStack {
                            Text("Card \(index + 1)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Swipe up/down or use toggle")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                    .id(index)
            }
        }
    }
}