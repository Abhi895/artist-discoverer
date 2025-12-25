import SwiftUI
import AVKit

struct SongsView: View {
    
    // Grid Layout
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    @ObservedObject private var feedManager = FeedManager.shared
    
    // Define a unique ID for this feed
    private let feedID = "songs"
    
    // Computed property to get liked videos from the source of truth

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Header Stats
            HStack {
                Text("\(feedManager.masterVideos.count) Liked Songs")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            ScrollView(showsIndicators: false) {
                // Check if we have liked videos
                if !feedManager.masterVideos.isEmpty {
                    LazyVGrid(columns: columns, spacing: 1) {
                        // Iterate through the liked videos
                        ForEach(Array(feedManager.masterVideos.enumerated()), id: \.offset) { index, video in
                            
                            // Navigation Link passing the Feed ID
                            NavigationLink(value: ActiveVideos(index: index, feedID: feedID)) {
                                
                                // Thumbnail Card
                                ZStack(alignment: .bottomLeading) {
                                    // Use the existing thumbnail generator
                                    if let url = video.url {
                                        VideoThumbnail(videoURL: url)
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .clipped()
                                    } else {
                                        Color.gray
                                            .aspectRatio(9/16, contentMode: .fill)
                                    }
                                    
                                    // Gradient Overlay
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.4)],
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                    
                                    // Play Icon Overlay
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                        .padding(6)
                                }
                                .aspectRatio(9/16, contentMode: .fit)
                            }
                        }
                    }
                } else {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No liked songs yet")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(height: 300)
                }
            }
        }
        .background(Color.tabBarBackground)
        .onAppear {
            feedManager.createFeed(id: feedID, videos: feedManager.masterVideos, autoPlay: false)
            feedManager.destroyFeed(id: "artists")
        }
    }
}

// MARK: - Async Thumbnail Generator (Kept largely the same, just ensured clean-up)
struct VideoThumbnail: View {
    let videoURL: URL
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
        }
        .onAppear {
            if image == nil { // optimization: don't regenerate if we have it
                generateThumbnail()
            }
        }
    }
    
    private func generateThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            // Generate from the middle or earlier to catch a good frame
            let time = CMTime(seconds: 0.0, preferredTimescale: 60)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            } catch {
                print("Thumbnail generation failed: \(error)")
            }
        }
    }
}
