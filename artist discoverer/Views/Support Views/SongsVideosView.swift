//
//  SongsVideosView.swift
//  artist discoverer
//
//  Full-screen video playback view
//

import SwiftUI
import AVKit

struct SongsVideosView: View {
        
    @ObservedObject private var videoManager = VideoManager.shared
    @State private var currentIndex: Int?

    let activeVideos: ActiveVideos
    var videos: [Video] {activeVideos.following ? videoManager.following : videoManager.videos}

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<videos.count, id: \.self) { index in
                    VideoCell(index: index, video: videos[index], preview: false, following: activeVideos.following)
                    .containerRelativeFrame(.vertical)
                    .id(index)

                }

            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .onChange(of: currentIndex) { _, newIndex in
            if let newIndex {
                videoManager.onScroll(to: newIndex)
            }
        }
        .onAppear {
            print(activeVideos.index)
            print(videos[activeVideos.index])
            print(videoManager.players)
            if videoManager.isMuted {
                videoManager.toggleMute()
            }
            
            currentIndex = activeVideos.index

            videoManager.resetFeed(newIndex: activeVideos.index)
        }
        .onDisappear {
            videoManager.pauseAllVideos()
        }
        .ignoresSafeArea(.all)
    }
       
}

struct ActiveVideos: Hashable, Equatable {
    let index: Int
    let urls: [URL]
    let following: Bool
}

