import SwiftUI

struct DailyWordsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        PerfectDailyWordsScrollView()
            .environmentObject(viewModel)
    }
}

#Preview {
    DailyWordsView()
        .environmentObject(HomeViewModel())
}
