import SwiftUI
import AVKit

struct SongsVideosView: View {
        
    @ObservedObject private var videoManager = VideoManager.shared
    @State private var scrollID: Int?

    // This struct now holds { index: Int, feedID: String }
    let activeVideos: ActiveVideos

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                
                // 1. Safely unwrap the feed using the ID passed from the previous screen
                if let feed = videoManager.feeds[activeVideos.feedID] {
                    
                    ForEach(0..<feed.videos.count, id: \.self) { index in
                        VideoCell(
                            index: index,
                            video: feed.videos[index],
                            feedID: activeVideos.feedID, // Pass the scalable ID
                            preview: false // Full screen mode (Enables play/pause gestures)
                        )
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
            if let newIndex {
                // 2. Scroll the specific feed (Isolated)
                videoManager.onScroll(to: newIndex, feedID: activeVideos.feedID)
            }
        }
        .onAppear {
            // 3. Jump to the selected video immediately
            scrollID = activeVideos.index
            
            // 4. Tell Manager to activate this specific player
            // This grabs the player instance already created by the Artist View
            videoManager.onScroll(to: activeVideos.index, feedID: activeVideos.feedID)
            
            // 5. Auto-Unmute when entering full screen (Better UX)
            if videoManager.isMuted {
                videoManager.toggleMute()
            }
        }
        .onDisappear {
            if activeVideos.feedID == "songs" {
                videoManager.pauseAllFeeds()
            }
        }
        .ignoresSafeArea(.all)
    }
}
struct ActiveVideos: Hashable {
    let index: Int
    let feedID: String // <--- Make sure this exists!
}
