import SwiftUI

struct ArtistsVideosView: View {
    
    @Binding var selectedTab: Tab
    @ObservedObject private var videoManager = VideoManager.shared
    
    private var videoURLs: [URL] {videoManager.following.compactMap { $0.url }}
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ForEach(0..<videoManager.following.count, id: \.self) { index in
                VStack {
                    HStack(alignment: .bottom) {

                        Image(videoManager.following[index].artistName.lowercased())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(videoManager.following[index].artistName)
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
                    
                    NavigationLink(value: ActiveVideos(index: index, urls: videoURLs, following: true)) {
                        VideoCard(following: videoManager.following, index: index)
                    }
                    .navigationDestination(for: ActiveVideos.self) { activeVids in
                        SongsVideosView(
                            activeVideos: activeVids
                        )
                    }

                    
                }
                .padding()
            }
        }
        .onPreferenceChange(VideoFrameKey.self) { preferences in
            detectActiveVideo(preferences: preferences)
        }
        .onAppear {
            if !videoManager.isMuted {
                videoManager.toggleMute()
            }
            
            videoManager.onScroll(to: 0)
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
//                print(closestIndex)
            }
        }
        
        // FIX 4: Use 'currentIndex' and 'onScroll(to:)'
        if closestIndex != -1 && closestIndex != videoManager.currentIndex {
            DispatchQueue.main.async {
                videoManager.onScroll(to: closestIndex)
            }
        }
    }
}

struct VideoFrameKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


struct VideoCard: View {
    
    var following: [Video]
    var index: Int
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            if index < following.count {
                VideoCell(
                    index: index,
                    video: following[index],
                    preview: true,
                    following: true
                )
                .aspectRatio(4/5, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.6), radius: 15, y: 10)
                .id(index)
                .allowsHitTesting(false)
                // FIX 1: Use 'currentIndex', not 'currentPlayingIndex'
                //                 .allowsHitTesting(index != videoManager.currentIndex)
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: VideoFrameKey.self,
                            value: [index: geometry.frame(in: .global)]
                        )
                })
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(following[index].songName)
                        .font(.system(size: 25, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    
                    FlowLayout(spacing: 5) {
                        ForEach(0..<min(3, following[index].hashtags.count), id: \.self) { i in
                            Button {
                                print("Hashtag tapped")
                            } label: {
                                Text(following[index].hashtags[i])
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
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary, lineWidth: 0.3)
        )
        .onAppear {
            print(following)
            print(index)
        }
    }

}
