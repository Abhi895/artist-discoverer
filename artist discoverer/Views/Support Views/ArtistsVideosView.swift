import SwiftUI

struct ArtistsVideosView: View {
    
    @Binding var selectedTab: Tab
    @ObservedObject private var videoManager = VideoManager.shared
    
    // 1. Define the unique ID for this specific feed
    private let feedID = "artists"
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            // 2. Only render the list if the feed has been created
            if let feed = videoManager.feeds[feedID] {
                
                ForEach(0..<feed.videos.count, id: \.self) { index in
                    let video = feed.videos[index]
                    
                    VStack {
                        // Header Section (Artist Info)
                        HStack(alignment: .bottom) {
                            Image(video.artistName.lowercased())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(video.artistName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                
                                Text("2h ago")
                                    .font(.system(size: 14, weight: .light, design: .default))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            Spacer()
                            
                            if index == 0 {
                                HStack {
                                    Text("Trending")
                                        .foregroundStyle(.white.opacity(0.6))
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                        .padding(4)
                        
                        // 3. Navigation Link passes the FeedID
                        NavigationLink(value: ActiveVideos(index: index, feedID: feedID)) {
                            VideoCard(video: video, index: index, feedID: feedID)
                        }
                    }
                    .padding()
                }
            } else {
                // Fallback / Loading state while feed creates
                ProgressView()
                    .padding()
            }
        }
        .onPreferenceChange(VideoFrameKey.self) { preferences in
            detectActiveVideo(preferences: preferences)
        }
        .onAppear {

            let followedVideos = videoManager.masterVideos.filter{$0.followingArtist}
            videoManager.createFeed(id: feedID, videos: followedVideos)
            videoManager.destroyFeed(id: "songs")
            
            // 5. Ensure Previews are Muted
            if !videoManager.isMuted {
                videoManager.toggleMute()
            }
        }
    }
    
    private func detectActiveVideo(preferences: [Int: CGRect]) {
        let screenCenterY = UIScreen.main.bounds.height / 2
        var closestIndex = -1
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for (index, frame) in preferences {
            let distance = abs(frame.midY - screenCenterY)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        // 7. Tell Manager to scroll the specific FEED, not the global state
        if let feed = videoManager.feeds[feedID],
           closestIndex != -1,
           closestIndex != feed.currentIndex {
            
            DispatchQueue.main.async {
                videoManager.onScroll(to: closestIndex, feedID: feedID)
            }
        }
    }
}

// MARK: - Video Card (Updated)

struct VideoCard: View {
    
    var video: Video
    var index: Int
    var feedID: String // Added feedID
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 8. Pass feedID to VideoCell so it grabs the correct Player
            VideoCell(
                index: index,
                video: video,
                feedID: feedID,
                preview: true // Important: This tells Cell to hide play buttons/overlays
            )
            .aspectRatio(4/5, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.6), radius: 15, y: 10)
            .id(index)
            .allowsHitTesting(false) // Disable interaction on preview
            .background(GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: VideoFrameKey.self,
                        value: [index: geometry.frame(in: .global)]
                    )
            })
            
            // Metadata Overlay
            VStack(alignment: .leading, spacing: 10) {
                Text(video.songName)
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                
                FlowLayout(spacing: 5) {
                    ForEach(0..<min(3, video.hashtags.count), id: \.self) { i in
                        Button {
                            print("Hashtag tapped")
                        } label: {
                            Text(video.hashtags[i])
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .padding(.horizontal, -2)
                                .padding(.vertical, -1)
                        }
                        .tint(.primary)
                        .buttonStyle(.glass)
                    }
                }
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary, lineWidth: 0.3)
        )
    }
}

struct VideoFrameKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

