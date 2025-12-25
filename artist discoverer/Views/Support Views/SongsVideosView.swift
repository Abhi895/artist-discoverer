import SwiftUI
import AVKit

struct SongsVideosView: View {
    
    @ObservedObject private var feedManager = FeedManager.shared
    @State private var scrollID: Int?
    //    @Binding var header: String
    
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
            
            //            VStack(alignment: .center) {
            //                Text(activeFeed.feedID == "songs" ? "LIKED SONGS" : "LATEST VIDEOS")
            //                    .navigationTitle(<#T##title: Text##Text#>)
            //                    .font(.system(size: 20, weight: .semibold, design: .default))
            //                    .foregroundStyle(.white.opacity(0.6))
            //                    .frame(maxWidth: .infinity)
            //                    .padding(-20)
            //                    .shadow(color: .black, radius: 15)
            //                Spacer()
            //            }
            
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrollID)
        .onChange(of: scrollID) { _, newIndex in
            if let newIndex {
                feedManager.onScroll(to: newIndex, feedID: activeFeed.feedID)
            }
        }
        .onAppear {
            //                self.header = activeFeed.feedID == "songs" ?  "LIKED SONGS" : "LATEST VIDEOS"
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
    }
}
struct ActiveFeed: Hashable {
    let index: Int
    let feedID: String
}
