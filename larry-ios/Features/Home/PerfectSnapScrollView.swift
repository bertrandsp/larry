import SwiftUI

struct PerfectSnapScrollView: View {
    @StateObject private var viewModel = VerticalCardViewModel()
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isSnapping: Bool = false
    @State private var scrollProxy: ScrollViewReader?
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Main scroll container
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                                VocabularyCardView(
                                    card: card,
                                    cardHeight: screenHeight,
                                    isActive: index == currentIndex
                                )
                                .frame(width: geometry.size.width, height: screenHeight)
                                .id(index)
                                .clipped()
                                .scaleEffect(getScaleEffect(for: index))
                                .opacity(getOpacity(for: index))
                                .animation(.easeOut(duration: 0.3), value: currentIndex)
                            }
                        }
                    }
                    .scrollDisabled(true) // We handle scrolling manually
                    .onAppear {
                        scrollProxy = proxy
                        viewModel.loadInitialCards()
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                handleDragChanged(value: value, screenHeight: screenHeight)
                            }
                            .onEnded { value in
                                handleDragEnded(value: value, screenHeight: screenHeight, proxy: proxy)
                            }
                    )
                }
                
                // Subtle page indicator (optional)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            ForEach(0..<min(viewModel.cards.count, 5), id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 6, height: 6)
                                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Ensure proper state when app becomes active
            if !isSnapping {
                snapToCurrentCard()
            }
        }
    }
    
    private func handleDragChanged(value: DragGesture.Value, screenHeight: CGFloat) {
        guard !isSnapping else { return }
        
        // Provide subtle visual feedback during drag
        let translation = value.translation.y
        let progress = abs(translation) / (screenHeight * 0.3)
        dragOffset = translation
        
        // Optional: Add subtle resistance at boundaries
        if (currentIndex == 0 && translation > 0) || 
           (currentIndex == viewModel.cards.count - 1 && translation < 0) {
            dragOffset = translation * 0.3 // Reduce drag effect at boundaries
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value, screenHeight: CGFloat, proxy: ScrollViewReader) {
        guard !isSnapping else { return }
        
        let translation = value.translation.y
        let velocity = value.velocity.y
        
        // More sensitive thresholds for better UX
        let translationThreshold: CGFloat = screenHeight * 0.12 // 12% of screen
        let velocityThreshold: CGFloat = 600
        
        var targetIndex = currentIndex
        
        // Determine swipe direction with velocity consideration
        if translation < -translationThreshold || velocity < -velocityThreshold {
            // Swipe up - next card
            targetIndex = min(currentIndex + 1, viewModel.cards.count - 1)
        } else if translation > translationThreshold || velocity > velocityThreshold {
            // Swipe down - previous card
            targetIndex = max(currentIndex - 1, 0)
        }
        
        // Always snap, even if staying on same card
        snapToCard(index: targetIndex, proxy: proxy)
    }
    
    private func snapToCard(index: Int, proxy: ScrollViewReader) {
        guard index >= 0 && index < viewModel.cards.count else { return }
        
        isSnapping = true
        dragOffset = 0
        
        // Smooth spring animation
        withAnimation(.interpolatingSpring(stiffness: 280, damping: 28, initialVelocity: 0)) {
            currentIndex = index
            proxy.scrollTo(index, anchor: .top)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Announce for accessibility
        announceCardChange(for: viewModel.cards[safe: index])
        
        // Check if we need to load more cards
        viewModel.checkAndLoadMoreCards(currentIndex: index)
        
        // Reset snapping flag with proper timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isSnapping = false
        }
    }
    
    private func snapToCurrentCard() {
        guard let proxy = scrollProxy else { return }
        snapToCard(index: currentIndex, proxy: proxy)
    }
    
    private func getScaleEffect(for index: Int) -> CGFloat {
        if index == currentIndex {
            return 1.0
        } else if abs(index - currentIndex) == 1 {
            return 0.95 // Slightly smaller for adjacent cards
        } else {
            return 0.9
        }
    }
    
    private func getOpacity(for index: Int) -> Double {
        if index == currentIndex {
            return 1.0
        } else if abs(index - currentIndex) == 1 {
            return 0.7 // Slightly transparent for adjacent cards
        } else {
            return 0.3
        }
    }
    
    private func announceCardChange(for card: VocabularyCard?) {
        guard let card = card else { return }
        
        let announcement = "Card \(currentIndex + 1) of \(viewModel.cards.count). \(card.term). \(card.definition)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - Alternative Implementation with UIPageViewController for Maximum Performance
struct HighPerformanceSnapScrollView: UIViewControllerRepresentable {
    @StateObject private var viewModel = VerticalCardViewModel()
    @Binding var currentIndex: Int
    
    init(currentIndex: Binding<Int> = .constant(0)) {
        self._currentIndex = currentIndex
    }
    
    func makeUIViewController(context: Context) -> HighPerformanceSnapViewController {
        let controller = HighPerformanceSnapViewController()
        controller.viewModel = viewModel
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: HighPerformanceSnapViewController, context: Context) {
        uiViewController.updateCards(viewModel.cards)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, HighPerformanceSnapViewControllerDelegate {
        let parent: HighPerformanceSnapScrollView
        
        init(_ parent: HighPerformanceSnapScrollView) {
            self.parent = parent
        }
        
        func didChangeToCard(at index: Int) {
            parent.currentIndex = index
        }
    }
}

protocol HighPerformanceSnapViewControllerDelegate: AnyObject {
    func didChangeToCard(at index: Int)
}

class HighPerformanceSnapViewController: UIViewController {
    var viewModel: VerticalCardViewModel?
    weak var delegate: HighPerformanceSnapViewControllerDelegate?
    
    private var pageViewController: UIPageViewController!
    private var cards: [VocabularyCard] = []
    private var currentIndex: Int = 0
    private var cardViewControllers: [Int: UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        loadInitialCards()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: [
                UIPageViewController.OptionsKey.spineLocation: UIPageViewController.SpineLocation.none,
                UIPageViewController.OptionsKey.interPageSpacing: 0
            ]
        )
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.didMove(toParent: self)
        
        // Configure scroll view for perfect snapping
        configureScrollView()
    }
    
    private func configureScrollView() {
        for subview in pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.isPagingEnabled = true
                scrollView.bounces = false
                scrollView.showsVerticalScrollIndicator = false
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.decelerationRate = .fast
                break
            }
        }
    }
    
    private func loadInitialCards() {
        viewModel?.loadInitialCards()
    }
    
    func updateCards(_ newCards: [VocabularyCard]) {
        let oldCount = cards.count
        cards = newCards
        
        // Set initial view controller if this is the first load
        if oldCount == 0 && !cards.isEmpty {
            let firstVC = getCardViewController(for: 0)
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    private func getCardViewController(for index: Int) -> UIViewController {
        // Reuse view controllers for better performance
        if let existingVC = cardViewControllers[index] {
            return existingVC
        }
        
        guard index < cards.count else { return UIViewController() }
        
        let hostingController = UIHostingController(
            rootView: VocabularyCardView(
                card: cards[index],
                cardHeight: view.bounds.height,
                isActive: index == currentIndex
            )
        )
        
        hostingController.view.backgroundColor = .clear
        cardViewControllers[index] = hostingController
        
        // Clean up old view controllers to prevent memory leaks
        if cardViewControllers.count > 5 {
            let keysToRemove = cardViewControllers.keys.filter { abs($0 - currentIndex) > 2 }
            keysToRemove.forEach { cardViewControllers.removeValue(forKey: $0) }
        }
        
        return hostingController
    }
}

// MARK: - UIPageViewController DataSource & Delegate
extension HighPerformanceSnapViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard currentIndex > 0 else { return nil }
        return getCardViewController(for: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard currentIndex < cards.count - 1 else { return nil }
        return getCardViewController(for: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // Update current index
            delegate?.didChangeToCard(at: currentIndex)
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Announce for accessibility
            let card = cards[currentIndex]
            let announcement = "Card \(currentIndex + 1) of \(cards.count). \(card.term). \(card.definition)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
            
            // Check if we need to load more cards
            viewModel?.checkAndLoadMoreCards(currentIndex: currentIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // Update current index for the transition
        // This is a bit tricky to determine, but we can use the view controller hierarchy
        // For now, we'll update this in didFinishAnimating
    }
}

#Preview {
    PerfectSnapScrollView()
}
