//
//  ArtistsView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 17/12/2025.
//

import AVKit
import SwiftUI

struct ArtistsView: View {
    @Binding var selectedTab: Tab

    @State private var currentVideoIndex = 0
    @ObservedObject private var videoManager = VideoManager.shared
    @State var noFavourites: Bool = true
    @State private var showEmptyState: Bool = false
    
    private var videoURLs: [URL] {
        var urls: [URL] = []
        
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            for url in videosFromRoot {
                for aristName in videoManager.following {
                    if url.lastPathComponent.contains(aristName) {
                        urls.append(url)
                    }
                }
            }
        }
        
        

        print("Found \(urls.count) video files:")
        for url in urls {
            print("  - \(url.lastPathComponent) at \(url.path)")
        }
        
        // If no videos found, add a sample remote video for testing
   
        return urls
    }
    
    // Create infinite loop of videos
    private var infiniteVideoURLs: [URL] {
        guard !videoURLs.isEmpty else { return [] }
        // Repeat the video array multiple times for infinite scrolling effect
        return Array(repeating: videoURLs, count: 1000).flatMap { $0 }
    }
    
    init(selectedTab: Binding<Tab>) {
        UITabBar.appearance().isHidden = true
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                HomeView()
                    .onAppear {
                        // Pause all videos when switching to other tabs
                        videoManager.pauseAllVideos()
                    }
            case .search:
                SearchView()
                    .onAppear {
                        // Pause all videos when switching to other tabs
                        videoManager.pauseAllVideos()
                    }
            case .profile:
                ProfileView()
                    .onAppear {
                        // Pause all videos when switching to other tabs
                        videoManager.pauseAllVideos()
                    }
            default:
                if videoURLs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.mic")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("You aren't following any artists yet")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        Text("Follow artists that you like to get updated when they drop new content")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.7))
                        Button {
                            selectedTab = .home
                            
                        } label: {
                            Text("Discover artists")
                                .font(.headline)
                                .frame(width: 200)
                                .padding(.vertical, 12)
                                .foregroundStyle(.white)
                        }
                        .glassEffect(.clear)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(colors: [Color.appBackground , Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea(.all)
                    )
                } else {
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
                }
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
            if selectedTab == .home {
                print("Initializing first video at index 0")
                videoManager.setCurrentPlaying(index: 0)
            }
        }
    }
}

//#Preview {
//    ArtistsView()
//}
