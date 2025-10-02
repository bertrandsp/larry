import SwiftUI

struct SnapScrollView: View {
    @StateObject private var viewModel = VerticalCardViewModel()
    @State private var currentIndex: Int = 0
    @State private var offset: CGFloat = 0
    @State private var isSnapping: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Main scroll container
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                            VocabularyCardView(
                                card: card,
                                cardHeight: screenHeight,
                                isActive: index == currentIndex
                            )
                            .frame(height: screenHeight)
                            .id(index)
                            .clipped()
                        }
                    }
                    .background(
                        GeometryReader { scrollGeometry in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: scrollGeometry.frame(in: .named("scroll")).minY
                                )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .scrollDisabled(true) // Disable default scrolling
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    offset = value
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isSnapping {
                                handleDragChanged(value: value, screenHeight: screenHeight)
                            }
                        }
                        .onEnded { value in
                            handleDragEnded(value: value, screenHeight: screenHeight)
                        }
                )
                .onAppear {
                    viewModel.loadInitialCards()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func handleDragChanged(value: DragGesture.Value, screenHeight: CGFloat) {
        // Provide immediate visual feedback during drag
        let translation = value.translation.height
        // You could add subtle visual feedback here if needed
    }
    
    private func handleDragEnded(value: DragGesture.Value, screenHeight: CGFloat) {
        guard !isSnapping else { return }
        
        let translation = value.translation.height
        let velocity = value.velocity.height
        
        // Thresholds for determining swipe direction
        let translationThreshold: CGFloat = screenHeight * 0.15 // 15% of screen
        let velocityThreshold: CGFloat = 800
        
        var targetIndex = currentIndex
        
        // Determine swipe direction
        if translation < -translationThreshold || velocity < -velocityThreshold {
            // Swipe up - next card
            targetIndex = min(currentIndex + 1, viewModel.cards.count - 1)
        } else if translation > translationThreshold || velocity > velocityThreshold {
            // Swipe down - previous card
            targetIndex = max(currentIndex - 1, 0)
        }
        
        // Snap to target card
        snapToCard(index: targetIndex, screenHeight: screenHeight)
    }
    
    private func snapToCard(index: Int, screenHeight: CGFloat) {
        guard index >= 0 && index < viewModel.cards.count else { return }
        
        isSnapping = true
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            currentIndex = index
        }
        
        // Announce for accessibility
        announceCardChange(for: viewModel.cards[safe: index])
        
        // Check if we need to load more cards
        viewModel.checkAndLoadMoreCards(currentIndex: index)
        
        // Reset snapping flag
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSnapping = false
        }
    }
    
    private func announceCardChange(for card: VocabularyCard?) {
        guard let card = card else { return }
        
        let announcement = "Card \(currentIndex + 1). \(card.term). \(card.definition)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - TabView Implementation (Alternative)
struct TabViewSnapScroll: View {
    @StateObject private var viewModel = VerticalCardViewModel()
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            TabView(selection: $currentIndex) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    VocabularyCardView(
                        card: card,
                        cardHeight: screenHeight,
                        isActive: index == currentIndex
                    )
                    .frame(height: screenHeight)
                    .clipped()
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .onAppear {
                viewModel.loadInitialCards()
            }
            .onChange(of: currentIndex) { newIndex in
                // Announce for accessibility
                announceCardChange(for: viewModel.cards[safe: newIndex])
                
                // Check if we need to load more cards
                viewModel.checkAndLoadMoreCards(currentIndex: newIndex)
            }
        }
        .ignoresSafeArea()
    }
    
    private func announceCardChange(for card: VocabularyCard?) {
        guard let card = card else { return }
        
        let announcement = "Card \(currentIndex + 1). \(card.term). \(card.definition)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - UIKit Implementation (Most Performant)
struct UIKitSnapScrollView: UIViewControllerRepresentable {
    @StateObject private var viewModel = VerticalCardViewModel()
    
    func makeUIViewController(context: Context) -> SnapScrollViewController {
        let controller = SnapScrollViewController()
        controller.viewModel = viewModel
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SnapScrollViewController, context: Context) {
        uiViewController.updateCards(viewModel.cards)
    }
}

class SnapScrollViewController: UIViewController {
    var viewModel: VerticalCardViewModel?
    private var pageViewController: UIPageViewController!
    private var cards: [VocabularyCard] = []
    private var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        loadInitialCards()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: [UIPageViewController.OptionsKey.spineLocation: UIPageViewController.SpineLocation.none]
        )
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        
        // Configure scroll view for better performance
        if let scrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.isPagingEnabled = true
            scrollView.bounces = false
            scrollView.showsVerticalScrollIndicator = false
        }
    }
    
    private func loadInitialCards() {
        viewModel?.loadInitialCards()
    }
    
    func updateCards(_ newCards: [VocabularyCard]) {
        cards = newCards
        
        if !cards.isEmpty && pageViewController.viewControllers?.isEmpty == true {
            let firstVC = createCardViewController(for: 0)
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    private func createCardViewController(for index: Int) -> UIViewController {
        guard index < cards.count else { return UIViewController() }
        
        let hostingController = UIHostingController(
            rootView: VocabularyCardView(
                card: cards[index],
                cardHeight: view.bounds.height,
                isActive: index == currentIndex
            )
        )
        
        hostingController.view.backgroundColor = .clear
        return hostingController
    }
}

// MARK: - UIPageViewController DataSource & Delegate
extension SnapScrollViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard currentIndex > 0 else { return nil }
        return createCardViewController(for: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard currentIndex < cards.count - 1 else { return nil }
        return createCardViewController(for: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // Update current index and announce for accessibility
            let announcement = "Card \(currentIndex + 1). \(cards[currentIndex].term). \(cards[currentIndex].definition)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
            
            // Check if we need to load more cards
            viewModel?.checkAndLoadMoreCards(currentIndex: currentIndex)
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
