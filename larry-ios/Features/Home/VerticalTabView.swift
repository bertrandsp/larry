import SwiftUI

enum ScrollMode {
    case snapToPage    // Fast snapping between cards
    case continuous    // Slow continuous scrolling
    case progressive   // Progressive scroll with peek and snap
}

struct VerticalTabView<Content: View>: View {
    let content: () -> Content
    let cardCount: Int
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var scrollMode: ScrollMode = .progressive
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    init(cardCount: Int = 5, @ViewBuilder content: @escaping () -> Content) {
        self.cardCount = cardCount
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
                        Text("Progressive").tag(ScrollMode.progressive)
                        Text("Snap").tag(ScrollMode.snapToPage)
                        Text("Scroll").tag(ScrollMode.continuous)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            content()
                        }
                    }
                    .scrollDisabled(scrollMode == .snapToPage || scrollMode == .progressive)
                    .offset(y: scrollMode == .progressive ? dragOffset : 0)
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
                        } else if newMode == .progressive {
                            // Reset drag offset when switching to progressive mode
                            dragOffset = 0
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: scrollMode == .progressive ? 0 : (scrollMode == .snapToPage ? 10 : 0))
                            .onChanged { value in
                                if scrollMode == .progressive {
                                    handleProgressiveDragChanged(value: value, screenHeight: screenHeight)
                                }
                            }
                            .onEnded { value in
                                if scrollMode == .progressive {
                                    handleProgressiveDragEnded(value: value, screenHeight: screenHeight) {
                                        proxy.scrollTo($0, anchor: .top)
                                    }
                                } else if scrollMode == .snapToPage {
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
    
    private func handleProgressiveDragChanged(value: DragGesture.Value, screenHeight: CGFloat) {
        isDragging = true
        
        // Calculate drag percentage (0-100% or 0 to -100%)
        let translation = value.translation.height
        let maxDrag = screenHeight * 0.8 // Allow dragging up to 80% of screen height
        
        // Apply boundary checks
        var clampedTranslation = translation
        
        // If on first card, don't allow dragging down (positive translation)
        if currentIndex == 0 && translation > 0 {
            clampedTranslation = max(0, min(maxDrag, translation))
        }
        // If on last card, don't allow dragging up (negative translation)
        else if currentIndex >= getCardCount() - 1 && translation < 0 {
            clampedTranslation = max(-maxDrag, min(0, translation))
        }
        // Normal case - allow full range
        else {
            clampedTranslation = max(-maxDrag, min(maxDrag, translation))
        }
        
        // Apply the drag offset for visual feedback
        dragOffset = clampedTranslation
    }
    
    private func handleProgressiveDragEnded(value: DragGesture.Value, screenHeight: CGFloat, scrollTo: @escaping (Int) -> Void) {
        isDragging = false
        
        // Prevent multiple simultaneous animations
        guard !isAnimating else { return }
        
        let translation = value.translation.height
        let velocity = value.velocity.height
        let screenHeight = screenHeight
        
        // Determine if we should snap to next/previous card
        let snapThreshold: CGFloat = screenHeight * 0.3 // 30% of screen height
        let velocityThreshold: CGFloat = 500
        
        var targetIndex = currentIndex
        
        if translation > snapThreshold || velocity > velocityThreshold {
            // Swipe down - go to previous card (only if not on first card)
            if currentIndex > 0 {
                targetIndex = currentIndex - 1
            }
        } else if translation < -snapThreshold || velocity < -velocityThreshold {
            // Swipe up - go to next card (only if not on last card)
            if currentIndex < getCardCount() - 1 {
                targetIndex = currentIndex + 1
            }
        }
        
        // Animate to target position
        if targetIndex != currentIndex {
            // Snap to next/previous card
            isAnimating = true
            currentIndex = targetIndex
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                dragOffset = 0
                scrollTo(currentIndex)
            } completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimating = false
                }
            }
        } else {
            // Snap back to current card
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                dragOffset = 0
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
    
    // Helper function to get card count
    private func getCardCount() -> Int {
        return cardCount
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
                            Text("Drag to peek next/previous")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            if index < 4 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 60)
                                    .overlay(
                                        Text("Next Card Preview")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    )
                                    .offset(y: UIScreen.main.bounds.height - 100)
                            }
                        }
                    )
                    .id(index)
            }
        }
    }
}