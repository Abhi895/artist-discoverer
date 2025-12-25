import SwiftUI
import AVKit
import Combine

// --- 1. The Isolated Context ---
// This holds everything unique to ONE specific feed (Home, Following, Search, etc.)
struct FeedContext {
    var id: String
    var videos: [Video] = []
    var players: [Int: AVQueuePlayer] = [:] // Isolated players
    var loopers: [Int: AVPlayerLooper] = [:] // Isolated loopers
    var currentIndex: Int = 0
    var paused: Bool = false
}

class VideoManager: ObservableObject {
    static let shared = VideoManager()

    @Published var feeds: [String: FeedContext] = [:]
    @Published var isMuted: Bool = false
    @Published var masterVideos: [Video] = []
    
    private var sessionID = UUID()
    
    init() {
        setupAudioSession()
        self.masterVideos = generateVideos()
        createFeed(id: "home", videos: masterVideos)
    }

    // MARK: - Feed Lifecycle
    
    func createFeed(id: String, videos: [Video], startIndex: Int = 0) {
        if var existing = feeds[id] {
            existing.videos = videos
            feeds[id] = existing
            return
        }
        
        // Create new isolated island
        print("✨ Creating Feed: \(id)")
        let newFeed = FeedContext(id: id, videos: videos, currentIndex: startIndex)
        feeds[id] = newFeed
        
        // Start loading ONLY for this island
        preload(index: startIndex, feedID: id)
        preload(index: startIndex + 1, feedID: id)
    }
    
    // Call this in .onDisappear to free memory
    func destroyFeed(id: String) {
        // We usually keep "home" alive, but destroy others to save RAM
        guard id != "home" else { return }
        
        if let feed = feeds[id] {
            print("🗑 Destroying Feed: \(id)")
            feed.players.values.forEach { $0.pause() }
            feed.players.values.forEach { $0.removeAllItems() }
            feeds.removeValue(forKey: id)
        }
    }
    
    // Add to VideoManager.swift
    func pauseAllFeeds() {
        for (_, feed) in feeds {
            feed.players.values.forEach { $0.pause() }
        }
    }
    
    // MARK: - Scrolling & Playing
    
    func onScroll(to index: Int, feedID: String) {
        guard var feed = feeds[feedID] else { return }
        
        // 1. Update Index
        feed.currentIndex = index
        
        // 2. Pause All *in this feed only*
        feed.players.values.forEach { $0.pause() }
        
        // 3. Play New
        if let player = feed.players[index] {
            if !feed.videos[index].paused {
                player.playImmediately(atRate: 1.0)
            }
        } else {
            // Save state before async load
            feeds[feedID] = feed
            preload(index: index, feedID: feedID)
            return
        }
        
        // 4. Save State
        feeds[feedID] = feed
        
        // 5. Preload Neighbors
        DispatchQueue.global(qos: .userInitiated).async {
            self.preload(index: index + 1, feedID: feedID)
            self.preload(index: index - 1, feedID: feedID)
        }
        
        cleanup(feedID: feedID)
    }
    
    // MARK: - Loading Logic
    
    private func preload(index: Int, feedID: String) {
        // Safe Read
        guard let feed = feeds[feedID],
              index >= 0, index < feed.videos.count,
              feed.players[index] == nil,
              let url = feed.videos[index].url else { return }
        
        let asset = AVURLAsset(url: url)
        
        Task {
            // Load Asset
            guard let isPlayable = try? await asset.load(.isPlayable), isPlayable else { return }
            
            await MainActor.run {
                // Re-Check (The feed might have been destroyed while loading)
                guard var currentFeed = self.feeds[feedID],
                      currentFeed.players[index] == nil else { return }
                
                let item = AVPlayerItem(asset: asset)
                let player = AVQueuePlayer(playerItem: item)
                player.isMuted = self.isMuted
                player.actionAtItemEnd = .none
                let looper = AVPlayerLooper(player: player, templateItem: item)
                
                // Save to Isolated Context
                currentFeed.players[index] = player
                currentFeed.loopers[index] = looper
                
                // Auto-play if user is still looking at this video
                if currentFeed.currentIndex == index {
                    player.playImmediately(atRate: 1.0)
                }
                
                // Write back to main dictionary
                self.feeds[feedID] = currentFeed
            }
        }
    }
    
    func cleanup(feedID: String) {
        guard var feed = feeds[feedID] else { return }
        
        // Remove players that are far away to save memory
        for (idx, player) in feed.players {
            if abs(idx - feed.currentIndex) > 2 {
                player.pause()
                feed.players.removeValue(forKey: idx)
                feed.loopers.removeValue(forKey: idx)
            }
        }
        feeds[feedID] = feed
    }
    
    // MARK: - Global Actions (The "Broadcast")
    
    func togglePlay(feedID: String, index: Int) {
        guard let player = feeds[feedID]?.players[index] else { return }
        feeds[feedID]?.videos[index].paused.toggle()
        player.timeControlStatus == .playing ? player.pause() : player.play()
    }
    
    func toggleMute() {
        isMuted.toggle()
        // Apply to ALL feeds
        for key in feeds.keys {
            feeds[key]?.players.values.forEach { $0.isMuted = isMuted }
        }
    }
    
    func toggleLike(videoId: Int) {
        if let idx = masterVideos.firstIndex(where: { $0.id == videoId }) {
            masterVideos[idx].liked.toggle()
        }
        
        for (feedID, var context) in feeds {
            if let index = context.videos.firstIndex(where: { $0.id == videoId }) {
                context.videos[index].liked.toggle()
                feeds[feedID] = context // Publish change
            }
        }
    }
    
    func toggleFollow(artistName: String) {
        for i in 0..<masterVideos.count {
            if masterVideos[i].artistName == artistName {
                masterVideos[i].followingArtist.toggle()
            }
        }
        
        // B. Broadcast to all active feeds
        for (feedID, var context) in feeds {
            var feedUpdated = false
            for i in 0..<context.videos.count {
                if context.videos[i].artistName == artistName {
                    context.videos[i].followingArtist.toggle()
                    feedUpdated = true
                }
            }
            if feedUpdated { feeds[feedID] = context }
        }
    }
    
    // Helper for UI
    func isLiked(videoId: Int, feedID: String) -> Bool {
        return feeds[feedID]?.videos.first(where: { $0.id == videoId })?.liked ?? false
    }
    
    func isFollowing(videoId: Int, feedID: String) -> Bool {
        return feeds[feedID]?.videos.first(where: { $0.id == videoId })?.followingArtist ?? false
    }
    
    func getPlayer(feedID: String, index: Int) -> AVQueuePlayer? {
        return feeds[feedID]?.players[index]
    }
    
    // MARK: - Setup / Mock Data
    func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func generateVideos() -> [Video] {
        var videos = [
            Video(artistName: "Demae", songDesc: "Step into the kaleidoscope.", hashtags: ["#neosoul"], songName: "Light"),
            Video(artistName: "Lloyiso", songDesc: "It’s terrifying when you aren't ready.", hashtags: ["#rnb"], songName: "Scary"),
            Video(artistName: "JERUB", songDesc: "Gathering 'round the fire.", hashtags: ["#fireside"], songName: "Kumbaya"),
            Video(artistName: "TYLER LEWIS", songDesc: "Still seeing shadows at the door?", hashtags: ["#rnbpop"], songName: "eventually"),
            Video(artistName: "PRYVT", songDesc: "Bringing it back to the streets.", hashtags: ["#indiepop"], songName: "PALETTE"),
            Video(artistName: "Only The Poets", songDesc: "Parking lot sessions.", hashtags: ["#indieband"], songName: "Saké"),
            Video(artistName: "SUMMER", songDesc: "Late night drives.", hashtags: ["#nightdrive"], songName: "stillxloveyou")
        ]
        let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) ?? []
        for i in 0..<min(videos.count, urls.count) { videos[i].id = i; videos[i].url = urls[i] }
        return videos
    }
}
