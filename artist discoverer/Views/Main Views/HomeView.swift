import SwiftUI

struct HomeView: View {
    @ObservedObject var feedManager = FeedManager.shared
    @State private var scrollID: Int?
    let feedID = "home"
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 2. Unwrap the specific feed data
                if let feed = feedManager.feeds[feedID] {
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
            if let i = newIndex { feedManager.onScroll(to: i, feedID: feedID) }
        }
        .onAppear {
            if feedManager.isMuted { feedManager.toggleMute() }
            scrollID = feedManager.feeds[feedID]?.currentIndex ?? 0
        }

        .ignoresSafeArea()
    }
}
