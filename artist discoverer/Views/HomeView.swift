//
//  SwiftUIView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 02/12/2025.
//

import SwiftUI
import AVKit
import UIKit
internal import Combine

// MARK: - DiscoverView
struct HomeView: View {
    //    @State var selectedTab: Tab = .discover
    
    @State private var currentVideoIndex = 0
    @ObservedObject private var videoManager = VideoManager.shared
    
    private var videoURLs: [URL] {
        var urls: [URL] = []
        
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            urls.append(contentsOf: videosFromRoot)
        }
        
        print("Found \(urls.count) video files:")
        for url in urls {
            print("  - \(url.lastPathComponent) at \(url.path)")
        }
        
        // If no videos found, add a sample remote video for testing
        if urls.isEmpty {
            print("No local videos found, using remote sample")
            if let remoteURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
                urls.append(remoteURL)
            }
        }
        
        return urls
    }
    
    // Create infinite loop of videos
    private var infiniteVideoURLs: [URL] {
        guard !videoURLs.isEmpty else { return [] }
        // Repeat the video array multiple times for infinite scrolling effect
        return Array(repeating: videoURLs, count: 1000).flatMap { $0 }
    }
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(infiniteVideoURLs.enumerated()), id: \.offset) { index, url in
                        VideoRowView(url: url, index: index)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: {
                videoManager.scrollPosition
            }, set: { newValue in
                if let newIndex = newValue {
                    print("Scroll position changed to: \(newIndex)")
                    currentVideoIndex = newIndex
                    videoManager.setCurrentPlaying(index: newIndex)
                }
            }))
            .ignoresSafeArea(.container, edges: .top)
        }
        .onAppear {
            // Reset to current video when returning to discover tab
            print("Discover view appeared, resetting to current video: \(currentVideoIndex)")
            videoManager.resetToIndex(currentVideoIndex)
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
            print("Initializing first video at index 0")
            videoManager.setCurrentPlaying(index: 0)
        }
    }
    
}


#Preview {
    HomeView()
}
