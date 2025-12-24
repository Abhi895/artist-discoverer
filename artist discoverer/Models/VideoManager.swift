import SwiftUI
import Combine
import AVKit
internal import System

class VideoManager: ObservableObject {
    static let shared = VideoManager()

    @Published var currentIndex: Int = 0
    @Published var paused: Bool = false
    
    static let emptyPlayer = AVPlayer()

    @Published var players: [Int:AVQueuePlayer] = [:]
    var loopers: [Int:AVPlayerLooper] = [:]
        
    @Published var videos: [Video] = []
    
    init() {
        videos = generateVideos()
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
        guard currentIndex != index else { return }
    
        if let oldPlayer = players[currentIndex] {
            oldPlayer.pause()
        }

        // Play current
        currentIndex = index
        paused = false
        
        if let player = players[index] {
            player.playImmediately(atRate: 1.0)
        } else {
            // WORST CASE: User scrolled too fast. Force load it.
            // Your preloadAsync's internal check "if self.currentIndex == index" will auto-play it when done.
            print("⚠️ Video \(index) not ready. Loading...")
            preloadAsync(index: index)
        }

        // 3. Preload neighbors (Optimized)
        // We use a background task to prepare next items so main thread doesn't hitch
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.preloadAsync(index: index + 1)
            self.preloadAsync(index: index - 1)
        }
        
        
        //        for i in (index-2)...(index+2) {
        //            _ = getPlayer(at: i)
        //        }
        //
        //        players.values.forEach { $0.pause() }
        //        players[index]?.playImmediately(atRate: 1.0)

        cleanUp(currentIndex: index)
    }

//    func getPlayer(at index: Int) -> AVPlayer? {
//        guard index >= 0 && index < videos.count else { return nil }
//
//        if let player = players[index] { return player }
//        guard let url = videos[index].url else { return nil }
//        
//        let asset = AVURLAsset(url: url)
//        let item = AVPlayerItem(asset: asset)
//        
//        let player = AVQueuePlayer(playerItem: item)
//        
//        player.automaticallyWaitsToMinimizeStalling = false
//        player.actionAtItemEnd = .none // Crucial for smooth looping
//
//        loopers[index] = AVPlayerLooper(player: player, templateItem: item)
//        players[index] = player
//        
//        return player
//    }
    
    private func preloadAsync(index: Int) {
        guard index >= 0 && index < videos.count else { return }
        guard players[index] == nil else { return }  // Early exit optimisation
        guard let url = videos[index].url else { return }

        let asset = AVURLAsset(url: url)

        Task { [weak self] in
            guard let self else { return }
            do {
                // Use the modern async property loading API introduced in iOS 16
                let isPlayable = try await asset.load(.isPlayable)
                guard isPlayable else {
                    print("Failed to load video at \(index): asset not playable")
                    return
                }

                await MainActor.run {
                    guard self.players[index] == nil else { return }

                    let item = AVPlayerItem(asset: asset)
                    let player = AVQueuePlayer(playerItem: item)
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

