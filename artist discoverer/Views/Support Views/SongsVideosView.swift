////
////  SongsVideosView.swift
////  artist discoverer
////
////  Full-screen video playback view
////
//
//import SwiftUI
//import AVKit
//
//struct SongsVideosView: View {
//    
//    let initialIndex: Int
//    let videoURLs: [URL]
//    let isFollowingContext: Bool
//    
//    @ObservedObject private var videoManager = VideoManager.shared
//    
//    // Default initializer for following context (from ArtistsVideosView)
//    init(initialIndex: Int, videoURLs: [URL]) {
//        self.initialIndex = initialIndex
//        self.videoURLs = videoURLs
//        self.isFollowingContext = true
//    }
//    
//    // Initializer for liked/all videos context (from SongsView or HomeView)
//    init(currentVideoIndex: Int) {
//        self.initialIndex = currentVideoIndex
//        self.videoURLs = VideoManager.shared.likedVideoURLs
//        self.isFollowingContext = false
//    }
//    
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(spacing: 0) {
//                    ForEach(Array(videoURLs.enumerated()), id: \.offset) { index, url in
//                        VideoRowView(
//                            url: url,
//                            index: index,
//                            isPreview: false,
//                            followingOnly: isFollowingContext
//                        )
//                        .containerRelativeFrame([.horizontal, .vertical])
//                        .id(index)
//                    }
//                }
//                .scrollTargetLayout()
//            }
//            .scrollTargetBehavior(.paging)
//            .scrollIndicators(.hidden)
//            .scrollPosition(id: .init(get: {
//                videoManager.currentPlayingIndex
//            }, set: { newValue in
//                if let newIndex = newValue {
//                    videoManager.setCurrentPlaying(index: newIndex)
//                }
//            }))
//            .ignoresSafeArea(.container, edges: .top)
//            .onAppear {
//                // Set the appropriate context
//                if isFollowingContext {
//                    videoManager.setContext(.custom(videoURLs))
//                } else {
//                    videoManager.setContext(.liked)
//                }
//                
//                // Enter full-screen mode
//                videoManager.enterFullScreen()
//                
//                // Scroll to correct position
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    proxy.scrollTo(initialIndex, anchor: .top)
//                    videoManager.setCurrentPlaying(index: initialIndex)
//                }
//            }
//            .onDisappear {
//                // Exit full-screen mode (immediately mutes and pauses)
//                videoManager.exitFullScreen()
//            }
//        }
//        .ignoresSafeArea(.keyboard)
//        .task {
//            // Configure audio session
//            try? AVAudioSession.sharedInstance().setCategory(
//                .playback,
//                mode: .moviePlayback,
//                options: [.allowAirPlay, .allowBluetoothA2DP]
//            )
//            try? AVAudioSession.sharedInstance().setActive(true)
//        }
//    }
//}
//
//struct ArtistPlaylist: Hashable {
//    let initialIndex: Int
//    let videos: [URL]
//}
