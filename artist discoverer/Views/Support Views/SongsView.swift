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
    @State private var likedVideos: [Video] = []
    @Binding var selectedTab: Tab
    
    private let feedID = "songs"
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if !likedVideos.isEmpty {
                
                HStack {
                    Text("\(likedVideos.count) Liked Songs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(Array(likedVideos.enumerated()), id: \.offset) { index, video in
                            NavigationLink(value: ActiveFeed(index: index, feedID: feedID)) {
                                ZStack(alignment: .bottomLeading) {
                                    if let url = video.url {
                                        VideoThumbnail(videoURL: url)
                                            .aspectRatio(9/16, contentMode: .fill)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .clipped()
                                    } else {
                                        Color.gray
                                            .aspectRatio(9/16, contentMode: .fill)
                                    }
                                    
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.4)],
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                        .padding(6)
                                }
                                .aspectRatio(9/16, contentMode: .fit)
                                .id(video.id)
                            }
                        }
                    }
                }
            } else {
                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: "music.note")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("You haven't liked any songs yet")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    Text("Like a song to easily come back to it whenever you want")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.7))
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = .home
                        }
                    } label: {
                        Text("Discover songs")
                            .font(.headline)
                            .frame(width: 200)
                            .padding(.vertical, 12)
                            .foregroundStyle(.white)
                    }
                    .glassEffect(.clear)
                    .padding()
                    
                }
                Spacer()

            }
        }
        .background(Color.tabBarBackground)
        .onAppear {
            self.likedVideos = feedManager.masterVideos.filter { $0.liked }
            feedManager.createFeed(id: feedID, videos: likedVideos, autoPlay: false)
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
