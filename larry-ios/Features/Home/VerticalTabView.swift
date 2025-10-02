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
    @State private var scrollMode: ScrollMode = .progressive
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var dragStartTime: Date = Date()
    
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
                        DragGesture(minimumDistance: 0)
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
        if !isDragging {
            isDragging = true
            dragStartTime = Date()
        }
        
        let translation = value.translation.height
        let maxDrag = screenHeight * 0.8 // Allow dragging up to 80% of screen height
        
        // Apply boundary checks with more restrictive clamping
        var clampedTranslation = translation
        
        // If on first card, don't allow dragging down (positive translation)
        if currentIndex == 0 && translation > 0 {
            clampedTranslation = max(0, min(maxDrag * 0.3, translation)) // More restrictive
        }
        // If on last card, don't allow dragging up (negative translation)
        else if currentIndex >= cardCount - 1 && translation < 0 {
            clampedTranslation = max(-maxDrag * 0.3, min(0, translation)) // More restrictive
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
        
        let translation = value.translation.height
        let velocity = value.velocity.height
        let dragDuration = Date().timeIntervalSince(dragStartTime)
        
        // Determine if we should snap to next/previous card
        let snapThreshold: CGFloat = screenHeight * 0.25 // 25% of screen height (more forgiving)
        let velocityThreshold: CGFloat = 300 // Lower velocity threshold
        
        var targetIndex = currentIndex
        
        // Use both distance and velocity for snap decision
        let shouldSnapDown = translation > snapThreshold || (velocity > velocityThreshold && dragDuration < 0.5)
        let shouldSnapUp = translation < -snapThreshold || (velocity < -velocityThreshold && dragDuration < 0.5)
        
        if shouldSnapDown && currentIndex > 0 {
            // Swipe down - go to previous card
            targetIndex = currentIndex - 1
        } else if shouldSnapUp && currentIndex < cardCount - 1 {
            // Swipe up - go to next card
            targetIndex = currentIndex + 1
        }
        
        // Animate to target position
        if targetIndex != currentIndex {
            // Snap to next/previous card
            currentIndex = targetIndex
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                dragOffset = 0
                scrollTo(currentIndex)
            }
        } else {
            // Snap back to current card - ensure we're properly aligned
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = 0
                // Force scroll to current index to ensure proper alignment
                scrollTo(currentIndex)
            }
        }
    }
    
    private func handleSnapGesture(value: DragGesture.Value, screenHeight: CGFloat, scrollTo: @escaping (Int) -> Void) {
        let translation = value.translation.height
        let velocity = value.velocity.height
        
        // More generous thresholds for better responsiveness
        let distanceThreshold: CGFloat = screenHeight * 0.12 // 12% of screen height
        let velocityThreshold: CGFloat = 400
        
        var targetIndex = currentIndex
        
        if translation > distanceThreshold || velocity > velocityThreshold {
            // Swipe down - go to previous card
            if currentIndex > 0 {
                targetIndex = currentIndex - 1
            }
        } else if translation < -distanceThreshold || velocity < -velocityThreshold {
            // Swipe up - go to next card
            if currentIndex < cardCount - 1 {
                targetIndex = currentIndex + 1
            }
        }
        
        // Only animate if we're actually changing cards
        if targetIndex != currentIndex {
            currentIndex = targetIndex
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                scrollTo(currentIndex)
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
                            Text("Drag to peek next/previous")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                    .id(index)
            }
        }
    }
}