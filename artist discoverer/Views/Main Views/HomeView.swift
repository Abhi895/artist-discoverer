import SwiftUI

struct HomeView: View {
    @ObservedObject var vm = VideoManager.shared
    @State private var scrollID: Int?
    let feedID = "home" // 1. Name your feed
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 2. Unwrap the specific feed data
                if let feed = vm.feeds[feedID] {
                    ForEach(0..<feed.videos.count, id: \.self) { index in
                        VideoCell(index: index, video: feed.videos[index], feedID: feedID, preview: false)
                            .containerRelativeFrame(.vertical)
                            .id(index)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrollID)
        .onChange(of: scrollID) { _, newIndex in
            // 3. Scroll specific feed
            if let i = newIndex { vm.onScroll(to: i, feedID: feedID) }
        }
        .onAppear {
            if vm.isMuted { vm.toggleMute() }
            scrollID = vm.feeds[feedID]?.currentIndex ?? 0
        }
        .ignoresSafeArea()
    }
}
