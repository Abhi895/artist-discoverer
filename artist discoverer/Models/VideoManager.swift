import SwiftUI
import Combine
import AVKit
internal import System

class VideoManager: ObservableObject {
    static let shared = VideoManager()

    @Published var videoss: [VideoModel] = []
    @Published var currentIndex: Int = 0
    
    static let emptyPlayer = AVPlayer()

    var players: [Int:AVQueuePlayer] = [:]
    var loopers: [Int:AVPlayerLooper] = [:]

    var videoURLs: [URL] {
        
        var urls: [URL] = []
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            urls.append(contentsOf: videosFromRoot)
        }
                
        return urls
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
    
    func onScroll(to index: Int) {
        
        print("I = \(index)")
        print(players)
        
        if let player = getPlayer(at: index) {
            print("PLAYING AT \(index)")
            player.playImmediately(atRate: 1.0)
        }
        
        if let prevPlayer = players[index-1] {
            print("PREV ADDED \(players)")
            print("PAUSING AT \(index - 1)")
            prevPlayer.pause()
        }
                
        if let nextPlayer = getPlayer(at: index+1) {
            print("NEXT ADDED -\(players)")
            print("PAUSING AT \(index + 1)")
            nextPlayer.pause()
        }
        
        cleanUp(currentIndex: index)
        print("CLEANED UP - \(players)")
    }

    func getPlayer(at index: Int) -> AVPlayer? {
        guard index >= 0 && index < videoURLs.count else { return nil }

        if let player = players[index] { return player }
        
        let item = AVPlayerItem(url: videoURLs[index])
        
//        item.preferredForwardBufferDuration = 3.0

        let player = AVQueuePlayer(playerItem: item)

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
