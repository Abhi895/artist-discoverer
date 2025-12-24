import SwiftUI
import Combine
import AVKit
internal import System

class VideoManager: ObservableObject {
    static let shared = VideoManager()

    @Published var currentIndex: Int = 0
    @Published var paused: Bool = false
    @Published var isMuted: Bool = false
    @Published var returningIndex: Int = 0
    @Published var useFollowing: Bool = false
    
    static let emptyPlayer = AVPlayer()

    @Published var players: [Int:AVQueuePlayer] = [:]
    var loopers: [Int:AVPlayerLooper] = [:]
        
    @Published var videos: [Video] = []
    @Published var following: [Video] = []
    
    init() {
        videos = generateVideos()
        
//        print(videos)
        
        
        setupAudioSession()
        preloadAsync(index: 0)
        preloadAsync(index: 1)
    }
    
    
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        // Apply to all currently loaded players immediately
        players.values.forEach { $0.isMuted = isMuted }
    }
    
    func pauseAllVideos() {
        
        if let currentPlayer = players[currentIndex] {
            currentPlayer.pause()
            paused = true
        }
        
        for (index, player) in players {
            if index != currentIndex {
                player.pause()
                player.removeAllItems()
                loopers[index] = nil
                players[index] = nil
            }
        }
    }
    
    func cleanUp(currentIndex: Int) {
        for (index, player) in players {
            if abs(index-currentIndex) > 2 {
                player.pause()
                players[index] = nil
                loopers[index] = nil
            }
        }
    }
    
    
    func onScroll(to index: Int) {
        print("SCROLLING")
        print("currentIndex - \(currentIndex)")
        print("index - \(index)")
        guard currentIndex != index || index == 0 else { return }
        print("PASSED CHECK")
        if let oldPlayer = players[currentIndex] {
            oldPlayer.pause()
        }

        currentIndex = index
        paused = false
        
        if let player = players[index] {
            player.playImmediately(atRate: 1.0)
        } else {
            print("⚠️ Video \(index) not ready. Loading...")
            preloadAsync(index: index)
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.preloadAsync(index: index + 1)
            self.preloadAsync(index: index - 1)
        }

        cleanUp(currentIndex: index)
    }
    
    func resumePlayback() {
        guard let player = players[currentIndex] else {
            preloadAsync(index: currentIndex)
            return
        }
        
        if !paused {
            player.playImmediately(atRate: 1.0)
        }
    }
    func resetFeed(newIndex: Int?) {
        // 1. Pause and Destroy EVERYTHING
        players.values.forEach { $0.pause() }
        players.values.forEach { $0.removeAllItems() }
        loopers.values.forEach { $0.disableLooping() }
        
        players.removeAll()
        loopers.removeAll()
        
        currentIndex = newIndex ?? 0 // Or specific index if restoring state
        paused = false
        
        // 3. Start Fresh
        // We trigger the first load immediately so the user sees something
        preloadAsync(index: newIndex ?? 0)
        
        // Preload next in background
        Task { [weak self] in
            if let ind = newIndex {
                print("PRELOADING")
                
                self?.preloadAsync(index: ind < self!.videos.count - 1 ? ind + 1: 0)
                
            } else {
                print("PRELOAIDNG AT 1")
                self?.preloadAsync(index: 1)
                
            }
        }
    }
    
    private func preloadAsync(index: Int) {
        let currVideos = useFollowing ? following : videos
//        print(currVideos)
        print("ATtEMPTED TO PRELOAD AT: \(index)")
        
        guard index >= 0 && index < currVideos.count else { return }
        print("PRELOADING WITH \(currVideos[index])")

        guard players[index] == nil else { return }
        guard let url = currVideos[index].url else { return }

        let asset = AVURLAsset(url: url)

        Task { [weak self] in
            guard let self else { return }
            do {
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    print("Failed to load video at \(index): asset not playable")
                    return
                }

                await MainActor.run {
                    guard self.players[index] == nil else { return }

                    let item = AVPlayerItem(asset: asset)
                    let player = AVQueuePlayer(playerItem: item)
                    player.isMuted = self.isMuted
                    player.automaticallyWaitsToMinimizeStalling = false
                    player.actionAtItemEnd = .none

                    self.loopers[index] = AVPlayerLooper(player: player, templateItem: item)
                    self.players[index] = player

                    if self.currentIndex == index {
                        player.playImmediately(atRate: 1.0)
                    }
                }
            } catch {
                print("Failed to load video at \(index): \(error.localizedDescription)")
            }
        }
    }
    
    func togglePlay(at index: Int) {
        if paused {
            players[index]?.play()
        } else {
            players[index]?.pause()
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            paused.toggle()
        }
    }
    
    
    func generateVideos() -> [Video] {
        var videos = [
                    Video(artistName: "Demae", songDesc: "Step into the kaleidoscope. 📺✨ 'Light' is a trip through my mind.", hashtags: ["#neosoul", "#retroaesthetic", "#visualart", "#groovy"], songName: "Light"),
                    Video(artistName: "Lloyiso", songDesc: "It’s terrifying when you aren't ready for love. 💔 wrote this at midnight.", hashtags: ["#rnbballad", "#emotionalvocals", "#heartbreak", "#soulmusic"], songName: "Scary"),
                    Video(artistName: "JERUB", songDesc: "Gathering 'round the fire with the people you love. 🔥 Finding peace in chaos.", hashtags: ["#fireside", "#acousticvibes", "#soulfulmusic", "#community"], songName: "Kumbaya"),
                    Video(artistName: "TYLER LEWIS", songDesc: "Still seeing shadows at the door? 🚪💔 We’re moving on, one step at a time.", hashtags: ["#rnbpop", "#breakupsong", "#movingon", "#newartist"], songName: "eventually"),
                    Video(artistName: "PRYVT", songDesc: "Bringing it back to the streets with this one. Just me and my guitar. 🎸✨", hashtags: ["#indiepop", "#streetperformer", "#chillvibes", "#guitarist"], songName: "PALETTE"),
                    Video(artistName: "Only The Poets", songDesc: "Parking lot sessions turning into core memories. 🚗💨 'Saké' is out now!", hashtags: ["#indieband", "#poprock", "#sake", "#bandlife"], songName: "Saké"),
                    Video(artistName: "SUMMER", songDesc: "Late night drives and memories I can't shake. 🌃🚗 'stillxloveyou' hits different.", hashtags: ["#nightdrive", "#popballad", "#heartbreakanthem", "#citylights"], songName: "stillxloveyou")
        ]
        
        let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) ?? []
        
        

        for (i, url) in urls.enumerated() {
            videos[i].id = i
            videos[i].url = url
        }
        
        return videos
    }
    
}

//protocol FeedManager {
//    func onScroll (to newIndex : Int)
//
//    func getPlayer (at index : Int) -> AVPlayer?
//}

