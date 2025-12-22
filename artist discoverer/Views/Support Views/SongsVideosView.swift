//
//  SongsVideosView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 22/12/2025.
//

import SwiftUI
import AVKit

struct SongsVideosView: View {
    
    @State var currentVideoIndex: Int
    @State var customVideoURLs: [URL]?
    @ObservedObject private var videoManager = VideoManager.shared
    
    @State private var infiniteVideoURLs: [URL] = []

    
    private func loadVideos() {
        
        if let customURLs = customVideoURLs, !customURLs.isEmpty {
            
            infiniteVideoURLs = customURLs
            
            print(infiniteVideoURLs)

        } else {
            
            var urls: [URL] = []
            
            if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
                urls.append(contentsOf: videosFromRoot)
            }
            
            // If no videos found, add a sample remote video for testing
            if urls.isEmpty {
                if let remoteURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
                    urls.append(remoteURL)
                }
            }
            
            if !urls.isEmpty {
                infiniteVideoURLs = urls
                
                print("III - \(infiniteVideoURLs[...6])")
            }
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(infiniteVideoURLs.enumerated()), id: \.offset) { index, url in
                        VideoRowView(url: url, index: index, preview: false, followingOnly: customVideoURLs != nil)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: {
                videoManager.currentPlayingIndex
            }, set: { newValue in
                if let newIndex = newValue {
                    print("Scroll position changed to: \(newIndex)")
                    currentVideoIndex = newIndex
                    videoManager.setCurrentPlaying(index: newIndex)
                    
                    print("INDEX - \(currentVideoIndex)")
                    print("CUSTOMMM - \(String(describing: customVideoURLs?[currentVideoIndex]))")
                    
                }
            }))
            .ignoresSafeArea(.container, edges: .top)
            .onAppear {
                
                videoManager.isFullScreenMode = true
                
                if infiniteVideoURLs.isEmpty {
                       loadVideos()
                   }

//                print("Discover view appeared, resetting to current video: \(currentVideoIndex)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(currentVideoIndex, anchor: .top)
                    videoManager.setCurrentPlaying(index: currentVideoIndex)
                    
                    print("INDEX - \(currentVideoIndex)")
                    print("CUSTOMMM - \(customVideoURLs?[currentVideoIndex])")
                    

                }
            }
            .onDisappear {
                
                videoManager.isFullScreenMode = true
                videoManager.pauseAllVideos()
            }
        }

        .ignoresSafeArea(.keyboard)
        .task {

            // Configure audio session for video playback
            try? AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.allowAirPlay, .allowBluetoothA2DP]
            )
            try? AVAudioSession.sharedInstance().setActive(true)
            
            // Initialize the first video
//            print("Initializing first video at index \(currentVideoIndex)")
//            videoManager.setCurrentPlaying(index: currentVideoIndex)
        }
    }
    
}

struct ArtistPlaylist: Hashable {
    let initialIndex: Int
    let videos: [URL]
}


//#Preview {
//    SongsVideosView()
//}
