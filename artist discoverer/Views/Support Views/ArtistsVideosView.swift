////
////  ArtistVideosView.swift
////  artist discoverer
////
////  Preview cards for followed artists
////
//
//import SwiftUI
//
//struct ArtistsVideosView: View {
//    
//    @Binding var selectedTab: Tab
//    @ObservedObject private var videoManager = VideoManager.shared
//    
//    // Get URLs for followed artists
//    private var videoURLs: [URL] {
//        return videoManager.followingVideoURLs
//    }
//    
//    init(selectedTab: Binding<Tab>) {
//        UITabBar.appearance().isHidden = true
//        self._selectedTab = selectedTab
//    }
//    
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            ForEach(Array(videoURLs.enumerated()), id: \.offset) { index, url in
//                VStack {
//                    // Header
//                    HStack(alignment: .bottom) {
//                        Image(videoManager.following[index].artistName.lowercased())
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 40, height: 40)
//                            .clipShape(Circle())
//                        
//                        VStack(alignment: .leading) {
//                            Text(videoManager.following[index].artistName)
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                .foregroundStyle(.white)
//                            
//                            Text("2h ago")
//                                .font(.system(size: 14, weight: .light, design: .default))
//                                .foregroundStyle(.white.opacity(0.6))
//                        }
//                        Spacer()
//                        
//                        if index == 0 {
//                            HStack {
//                                Text("Trending")
//                                    .foregroundStyle(.white.opacity(0.6))
//                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
//                                Image(systemName: "chart.line.uptrend.xyaxis")
//                                    .foregroundStyle(.white.opacity(0.6))
//                            }
//                        }
//                    }
//                    .padding(4)
//                    
//                    // Video Preview Card
//                    NavigationLink(value: ArtistPlaylist(initialIndex: index, videos: videoURLs)) {
//                        ZStack(alignment: .bottomLeading) {
//                            VideoRowView(
//                                url: url,
//                                index: index,
//                                isPreview: true,
//                                followingOnly: true
//                            )
//                            .aspectRatio(4/5, contentMode: .fit)
//                            .frame(maxWidth: .infinity)
//                            .clipShape(RoundedRectangle(cornerRadius: 24))
//                            .shadow(color: .black.opacity(0.6), radius: 15, y: 10)
//                            .id(index)
//                            .allowsHitTesting(index != videoManager.currentPlayingIndex)
//                            .background(GeometryReader { geometry in
//                                Color.clear
//                                    .preference(
//                                        key: VideoFrameKey.self,
//                                        value: [index: geometry.frame(in: .global)]
//                                    )
//                            })
//                            
//                            // Song info overlay
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(videoManager.following[index].songName)
//                                    .font(.system(size: 25, weight: .bold, design: .serif))
//                                    .foregroundStyle(.white)
//                                
//                                FlowLayout(spacing: 5) {
//                                    ForEach(0..<min(3, videoManager.following[index].hashtags.count), id: \.self) { i in
//                                        Button {
//                                            print("Hashtag tapped")
//                                        } label: {
//                                            Text(videoManager.following[index].hashtags[i])
//                                                .font(.system(size: 12, weight: .regular, design: .monospaced))
//                                                .padding(.horizontal, -2)
//                                                .padding(.vertical, -1)
//                                        }
//                                        .tint(.primary)
//                                        .buttonStyle(.glass)
//                                    }
//                                }
//                            }
//                            .padding()
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//        .navigationDestination(for: ArtistPlaylist.self) { playlist in
//            SongsVideosView(
//                initialIndex: playlist.initialIndex,
//                videoURLs: playlist.videos
//            )
//        }
//        .onPreferenceChange(VideoFrameKey.self) { preferences in
//            detectActiveVideo(preferences: preferences)
//        }
//        .onAppear {
//            // Set context to following for previews
//            videoManager.setContext(.following)
//            
//            // Exit full-screen if coming back from it
//            if videoManager.isFullScreenMode {
//                videoManager.exitFullScreen()
//            }
//            
//            // Reset playback
//            videoManager.resetToIndex(videoManager.currentPlayingIndex)
//        }
//    }
//    
//    private func detectActiveVideo(preferences: [Int: CGRect]) {
//        let screenCenterY = UIScreen.main.bounds.height / 2
//        
//        var closestIndex = -1
//        var minDistance = CGFloat.greatestFiniteMagnitude
//        
//        for (index, frame) in preferences {
//            let distance = abs(frame.midY - screenCenterY)
//            if distance < minDistance {
//                minDistance = distance
//                closestIndex = index
//            }
//        }
//        
//        if closestIndex != -1 && closestIndex != videoManager.currentPlayingIndex {
//            DispatchQueue.main.async {
//                videoManager.setCurrentPlaying(index: closestIndex)
//            }
//        }
//    }
//}
//
//// MARK: - Preference Key
//
//struct VideoFrameKey: PreferenceKey {
//    typealias Value = [Int: CGRect]
//    static var defaultValue: [Int: CGRect] = [:]
//    
//    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
//        value.merge(nextValue(), uniquingKeysWith: { $1 })
//    }
//}
