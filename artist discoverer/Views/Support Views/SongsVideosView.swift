import SwiftUI
import AVKit

struct SongsVideosView: View {
        
    @ObservedObject private var feedManager = FeedManager.shared
    @State private var scrollID: Int?

    let activeFeed: ActiveFeed

    var body: some View {
        
        ZStack {
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let feed = feedManager.feeds[activeFeed.feedID] {
                        
                        ForEach(0..<feed.videos.count, id: \.self) { index in
                            VideoCell(
                                index: index,
                                video: feed.videos[index],
                                feedID: activeFeed.feedID,
                                preview: false
                            )
                            .containerRelativeFrame(.vertical)
                            .id(index)
                        }
                    }
                }
                .scrollTargetLayout()
            }
        
            VStack(alignment: .center) {
                Text(activeFeed.feedID == "songs" ? "LIKED SONGS" : "LATEST VIDEOS")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding()
                Spacer()
            }

        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrollID)
        .onChange(of: scrollID) { _, newIndex in
            if let newIndex {
                feedManager.onScroll(to: newIndex, feedID: activeFeed.feedID)
            }
        }
        .onAppear {
            scrollID = activeFeed.index
            feedManager.onScroll(to: activeFeed.index, feedID: activeFeed.feedID)
            
            if feedManager.isMuted {
                feedManager.toggleMute()
            }
        }
        .onDisappear {
            if activeFeed.feedID == "songs" {
                feedManager.pauseAllFeeds()
            }
        }
        .ignoresSafeArea(.all)
    }
}
struct ActiveFeed: Hashable {
    let index: Int
    let feedID: String
}
