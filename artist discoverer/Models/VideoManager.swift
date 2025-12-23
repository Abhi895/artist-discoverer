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
        // Preload first two videos immediately
        _ = getPlayer(at: 0)
        if videos.count > 1 {
            _ = getPlayer(at: 1)
        }
//        players[0]?.play()
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
        
        lazy var videoURLs: [URL] = {
            Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil)!
        }()
        
        

        for (i, url) in videoURLs.enumerated() {
            videos[i].id = i
            videos[i].url = url
        }
        
        return videos
    }
    
    func cleanUp(currentIndex: Int) {
        for (index, player) in players {
            if abs(index-currentIndex) > 1 {
                player.pause()
                players[index] = nil
                loopers[index] = nil
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
    
    func onScroll(to index: Int) {
        paused = false
        currentIndex = index
//        print("I = \(index)")
//        print(players)
        
        for i in (index-2)...(index+2) {
            _ = getPlayer(at: i)
        }
        
        players.values.forEach { $0.pause() }
        players[index]?.playImmediately(atRate: 1.0)
//
//
//
//        if let player = getPlayer(at: index) {
//            print("PLAYING AT \(index)")
//            player.playImmediately(atRate: 1.0)
//        }
//
//        if let prevPlayer = players[index-1] {
//            print("PREV ADDED \(players)")
//            print("PAUSING AT \(index - 1)")
//            prevPlayer.pause()
//        }
//
//        if let nextPlayer = getPlayer(at: index+1) {
//            print("NEXT ADDED -\(players)")
//            print("PAUSING AT \(index + 1)")
//            nextPlayer.pause()
//        }
//
        cleanUp(currentIndex: index)
    }

    func getPlayer(at index: Int) -> AVPlayer? {
        guard index >= 0 && index < videos.count else { return nil }

        if let player = players[index] { return player }
        
        let item = AVPlayerItem(url: videos[index].url!)
        let player = AVQueuePlayer(playerItem: item)
        
        player.automaticallyWaitsToMinimizeStalling = false

        loopers[index] = AVPlayerLooper(player: player, templateItem: item)
        players[index] = player
        
        return player
    }
    

}

//protocol FeedManager {
//    func onScroll (to newIndex : Int)
//
//    func getPlayer (at index : Int) -> AVPlayer?
//}
