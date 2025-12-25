import SwiftUI
import AVKit
import Combine

// --- 1. The Isolated Context ---
// This holds everything unique to ONE specific feed (Home, Following, Search, etc.)

class FeedManager: ObservableObject {
    static let shared = FeedManager()

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
    
    // In VideoManager.swift

    func createFeed(id: String, videos: [Video], startIndex: Int = 0, autoPlay: Bool = true) {
        
        // 1. Check if feed exists
        if let existing = feeds[id] {
            
            // 2. STALENESS CHECK: Are the videos the same?
            // We compare the IDs. If they match, the feed is good. We do nothing.
            let existingIDs = existing.videos.map { $0.id }
            let newIDs = videos.map { $0.id }
            
            if existingIDs == newIDs {
                return // Feed is up to date!
            }
            
            // 3. If they differ (e.g. you unliked a song), we must destroy the old stale feed
            print("⚠️ Feed '\(id)' is stale. Refreshing...")
            destroyFeed(id: id)
        }
        
        // 4. Create fresh feed (This runs if feed didn't exist OR if we just destroyed it)
        print("✨ Creating Feed: \(id)")
        let newFeed = FeedContext(id: id, videos: videos, currentIndex: startIndex)
        feeds[id] = newFeed
        
        preload(index: startIndex, feedID: id, autoPlay: autoPlay)
        preload(index: startIndex + 1, feedID: id, autoPlay: false)
    }
    
    func destroyFeed(id: String) {
        guard id != "home" else { return }
        
        if let feed = feeds[id] {
            print("🗑 Destroying Feed: \(id)")
            feed.players.values.forEach { $0.pause() }
            feed.players.values.forEach { $0.removeAllItems() }
            feeds.removeValue(forKey: id)
        }
    }
    
    func pauseAllFeeds() {
        for (_, feed) in feeds {
            feed.players.values.forEach { $0.pause() }
        }
    }
    
    
    func onScroll(to index: Int, feedID: String) {
        guard var feed = feeds[feedID] else { return }
        
        feed.currentIndex = index
        
        feed.players.values.forEach { $0.pause() }
        
        if let player = feed.players[index] {
            if !feed.videos[index].paused {
                player.playImmediately(atRate: 1.0)
            }
        } else {
            feeds[feedID] = feed
            preload(index: index, feedID: feedID, autoPlay: true)
            return
        }
        
        feeds[feedID] = feed
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.preload(index: index + 1, feedID: feedID, autoPlay: false)
            self.preload(index: index - 1, feedID: feedID, autoPlay: false)
        }
        
        cleanup(feedID: feedID)
    }
    
    // MARK: - Loading Logic
    
    private func preload(index: Int, feedID: String, autoPlay: Bool) {
        guard let feed = feeds[feedID],
              index >= 0, index < feed.videos.count,
              feed.players[index] == nil,
              let url = feed.videos[index].url else { return }
        
        let asset = AVURLAsset(url: url)
        
        Task {
            guard let isPlayable = try? await asset.load(.isPlayable), isPlayable else { return }
            
            await MainActor.run {
                guard var currentFeed = self.feeds[feedID],
                      currentFeed.players[index] == nil else { return }
                
                let item = AVPlayerItem(asset: asset)
                let player = AVQueuePlayer(playerItem: item)
                player.isMuted = self.isMuted
                player.actionAtItemEnd = .none
                let looper = AVPlayerLooper(player: player, templateItem: item)
                
                currentFeed.players[index] = player
                currentFeed.loopers[index] = looper
                
                if currentFeed.currentIndex == index && autoPlay {
                    player.playImmediately(atRate: 1.0)
                }
                
                self.feeds[feedID] = currentFeed
            }
        }
    }
    
    func cleanup(feedID: String) {
        guard var feed = feeds[feedID] else { return }
        
        for (idx, player) in feed.players {
            if abs(idx - feed.currentIndex) > 2 {
                player.pause()
                feed.players.removeValue(forKey: idx)
                feed.loopers.removeValue(forKey: idx)
            }
        }
        feeds[feedID] = feed
    }
    
    func togglePlay(feedID: String, index: Int) {
        guard let player = feeds[feedID]?.players[index] else { return }
        feeds[feedID]?.videos[index].paused.toggle()
        player.timeControlStatus == .playing ? player.pause() : player.play()
    }
    
    func toggleMute() {
        isMuted.toggle()
        // Apply to ALL videoManager.feeds
        for key in feeds.keys {
            feeds[key]?.players.values.forEach { $0.isMuted = isMuted }
        }
    }
    
    func getPlayer(feedID: String, index: Int) -> AVQueuePlayer? {
        return feeds[feedID]?.players[index]
    }
    
    func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func generateVideos() -> [Video] {
        var videos = [
            Video(artistName: "Demae", songDesc: "Step into the kaleidoscope. 📺✨ 'Light' is a trip through my mind.", hashtags: ["#neosoul", "#retroaesthetic", "#visualart", "#groovy"], songName: "Light"),
            Video(artistName: "Lloyiso", songDesc: "It's terrifying when you aren't ready for love. 💔 wrote this at midnight.", hashtags: ["#rnbballad", "#emotionalvocals", "#heartbreak", "#soulmusic"], songName: "Scary"),
            Video(artistName: "JERUB", songDesc: "Gathering 'round the fire with the people you love. 🔥 Finding peace in chaos.", hashtags: ["#fireside", "#acousticvibes", "#soulfulmusic", "#community"], songName: "Kumbaya"),
            Video(artistName: "TYLER LEWIS", songDesc: "Still seeing shadows at the door? 🚪💔 We're moving on, one step at a time.", hashtags: ["#rnbpop", "#breakupsong", "#movingon", "#newartist"], songName: "eventually"),
            Video(artistName: "PRYVT", songDesc: "Bringing it back to the streets with this one. Just me and my guitar. 🎸✨", hashtags: ["#indiepop", "#streetperformer", "#chillvibes", "#guitarist"], songName: "PALETTE"),
            Video(artistName: "Only The Poets", songDesc: "Parking lot sessions turning into core memories. 🚗💨 'Saké' is out now!", hashtags: ["#indieband", "#poprock", "#sake", "#bandlife"], songName: "Saké"),
            Video(artistName: "SUMMER", songDesc: "Late night drives and memories I can't shake. 🌃🚗 'stillxloveyou' hits different.", hashtags: ["#nightdrive", "#popballad", "#heartbreakanthem", "#citylights"], songName: "stillxloveyou")
        ]
        
        let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) ?? []
        for i in 0..<min(videos.count, urls.count) { videos[i].id = i; videos[i].url = urls[i] }
        return videos
    }
}
