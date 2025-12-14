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

// MARK: - Video Manager


// MARK: - VideoRowView
struct VideoRowView: View {
    let url: URL
    let index: Int
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var debugInfo = "Loading..."
    @ObservedObject private var videoManager = VideoManager.shared
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayerView(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
            } else {
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
                
                VStack {
                    Text(debugInfo)
                        .foregroundColor(.white)
                        .padding()
                    Text("File: \(url.lastPathComponent)")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text("Index: \(index)")
                        .foregroundColor(.blue)
                        .font(.caption2)
                }
            }
            
            if showPlayButton {
                Button(action: {
                    // When manually playing via button, set this as current and play
                    videoManager.setCurrentPlaying(index: index)
                    videoManager.userPlayedCurrentVideo()
                    playVideo()
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Simple toggle: if playing -> pause and show button, if paused -> play and hide button
            if isPlaying {
                pauseVideo()
                videoManager.userPausedCurrentVideo() // Track that user manually paused
                withAnimation(.easeInOut(duration: 0.2)) {
                    showPlayButton = true
                }
            } else {
                // When manually playing, set this as current and play
                videoManager.setCurrentPlaying(index: index)
                videoManager.userPlayedCurrentVideo() // Track that user manually played
                playVideo()
            }
        }
        .onAppear {
            setupPlayer()
            // Start with button hidden
            showPlayButton = false
        }
        .onDisappear {
            pauseVideo()
        }
        .onChange(of: videoManager.currentPlayingIndex) { oldValue, newValue in
            print("Video \(index): VideoManager index changed from \(oldValue) to \(newValue)")
            
            if newValue == index {
                // This video should be playing - but only if user hasn't manually paused it
                if !isPlaying && player != nil && !videoManager.userHasPausedCurrentVideo {
                    print("Video \(index): Starting playback because this is current and user hasn't paused")
                    playVideo() // This will hide the button
                } else if videoManager.userHasPausedCurrentVideo {
                    print("Video \(index): Not auto-playing because user paused this video")
                    // Show play button since user paused it
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showPlayButton = true
                    }
                }
            } else {
                // This video should be paused (either different video or pause all)
                if isPlaying {
                    print("Video \(index): Pausing because current is \(newValue)")
                    pauseVideo()
                    // Don't show button here - let user interaction control button visibility
                }
            }
        }
    }
    
    private func setupPlayer() {
        print("Setting up player for: \(url.lastPathComponent) at index \(index)")
        print("Full URL: \(url)")
        debugInfo = "Setting up player..."
        
        // Check if file exists (for bundled files)
        if url.isFileURL {
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("File exists: \(fileExists)")
            if !fileExists {
                debugInfo = "File not found: \(url.lastPathComponent)"
                return
            }
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        debugInfo = "Player created, checking status..."
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                if let player = player {
                    let status = player.currentItem?.status
                    switch status {
                    case .readyToPlay:
                        debugInfo = "Ready to play!"
                        // Only start playing if this is the current video and user hasn't paused it
                        if videoManager.currentPlayingIndex == index && !videoManager.userHasPausedCurrentVideo {
                            print("Auto-playing video at index \(index) because it's current and user hasn't paused")
                            playVideo()
                        } else {
                            print("Not auto-playing video at index \(index) because current is \(videoManager.currentPlayingIndex) or user paused it")
                            if videoManager.userHasPausedCurrentVideo && videoManager.currentPlayingIndex == index {
                                // Show play button if user paused this video
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showPlayButton = true
                                }
                            }
                        }
                    case .failed:
                        debugInfo = "Failed to load: \(player.currentItem?.error?.localizedDescription ?? "Unknown error")"
                        print("Player failed: \(player.currentItem?.error?.localizedDescription ?? "Unknown")")
                    case .unknown:
                        debugInfo = "Status unknown"
                    case .none:
                        debugInfo = "No player item"
                    @unknown default:
                        debugInfo = "Unknown status"
                    }
                }
            }
        }
        
        // Loop the video when it ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("Video ended, looping: \(url.lastPathComponent)")
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    private func playVideo() {
        guard let player = player else { 
            debugInfo = "No player available"
            return 
        }
        print("Starting playback for: \(url.lastPathComponent) at index \(index)")
        debugInfo = "Playing..."
        player.isMuted = false // Unmute when playing
        player.play()
        isPlaying = true
        
        // Always hide play button when video starts playing
        withAnimation(.easeInOut(duration: 0.2)) {
            showPlayButton = false
        }
    }
    
    private func pauseVideo() {
        guard let player = player else { return }
        print("Pausing video: \(url.lastPathComponent) at index \(index)")
        debugInfo = "Paused"
        player.pause()
        player.isMuted = true // Mute when paused
        isPlaying = false
    }

}

// MARK: - VideoPlayerView
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        let view = VideoPlayerUIView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        uiView.player = player
    }
}

final class VideoPlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}



// MARK: - DiscoverView
struct DiscoverView: View {
    @State private var selectedTab: Tab = .discover
    @State private var currentVideoIndex = 0
    @ObservedObject private var videoManager = VideoManager.shared
    
    // Get all video URLs from bundle
    private var videoURLs: [URL] {
        // Try different approaches to find videos
        var urls: [URL] = []
        
        // First try: videos subdirectory
        if let videosFromSubdir = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "videos") {
            urls.append(contentsOf: videosFromSubdir)
        }
        
        // Second try: root of bundle
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            urls.append(contentsOf: videosFromRoot)
        }
        
        // Third try: any .mov files
        if let movFiles = Bundle.main.urls(forResourcesWithExtension: "mov", subdirectory: nil) {
            urls.append(contentsOf: movFiles)
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
        VStack(spacing: 0) {
            switch selectedTab {
            case .favourites:
                FavouritesView()
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
            
            CustomTabBar(selectedTab: $selectedTab)
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
            if selectedTab == .discover {
                print("Initializing first video at index 0")
                videoManager.setCurrentPlaying(index: 0)
            }
        }
    }
}

#Preview {
    DiscoverView()
}
