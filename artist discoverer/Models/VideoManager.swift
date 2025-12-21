//
//  VideoManager.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 14/12/2025.
//

import SwiftUI
internal import Combine

class VideoManager: ObservableObject {
    static let shared = VideoManager()
    @Published var currentPlayingIndex: Int = 0
    @Published var scrollPosition: Int = 0
    @Published var userHasPausedCurrentVideo: Bool = false
    @Published var songsInfo: [Song] = [
        Song(artistName: "ANXTI", songDesc: "The confusion of heartbreak — asking yourself if what you had was even real. Hope you feel this. 🎙️💔", hashtags: ["#heartbreak", "#rawvocals", "#indiepop", "#latenight"], songName: "WHERE DID YOU GO"),
        Song(artistName: "Demae", songDesc: "Step into the kaleidoscope. 📺✨ 'Light' is a trip through my mind.", hashtags: ["#neosoul", "#retroaesthetic", "#visualart", "#groovy"], songName: "Light"),
             Song(artistName: "Lloyiso", songDesc: "It’s terrifying when you aren't ready for love. 💔 wrote this at midnight.", hashtags: ["#rnbballad", "#emotionalvocals", "#heartbreak", "#soulmusic"], songName: "Scary"),
             Song(artistName: "JERUB", songDesc: "Gathering 'round the fire with the people you love. 🔥 Finding peace in chaos.", hashtags: ["#fireside", "#acousticvibes", "#soulfulmusic", "#community"], songName: "Kumbaya"),
             Song(artistName: "TYLER LEWIS", songDesc: "Still seeing shadows at the door? 🚪💔 We’re moving on, one step at a time.", hashtags: ["#rnbpop", "#breakupsong", "#movingon", "#newartist"], songName: "eventually"),
             Song(artistName: "PRYVT", songDesc: "Bringing it back to the streets with this one. Just me and my guitar. 🎸✨", hashtags: ["#indiepop", "#streetperformer", "#chillvibes", "#guitarist"], songName: "PALETTE"),
             Song(artistName: "Only The Poets", songDesc: "Parking lot sessions turning into core memories. 🚗💨 'Saké' is out now!", hashtags: ["#indieband", "#poprock", "#sake", "#bandlife"], songName: "Saké"),
             Song(artistName: "SUMMER", songDesc: "Late night drives and memories I can't shake. 🌃🚗 'stillxloveyou' hits different.", hashtags: ["#nightdrive", "#popballad", "#heartbreakanthem", "#citylights"], songName: "stillxloveyou")
    ]
    @Published var following: [String] = []
    
    private init() {}
    
    func setCurrentPlaying(index: Int) {
        print("VideoManager: Setting current playing to index \(index)")
        currentPlayingIndex = index
        scrollPosition = index
        userHasPausedCurrentVideo = false
    }
    
    func pauseAllVideos() {
        print("VideoManager: Pausing all videos")
        currentPlayingIndex = -1
    }
    
    func resetToIndex(_ index: Int) {
        print("VideoManager: Resetting to index \(index)")
        currentPlayingIndex = index
        scrollPosition = index
    }
    
    func userPausedCurrentVideo() {
        print("VideoManager: User paused current video")
        userHasPausedCurrentVideo = true
    }
    
    func userPlayedCurrentVideo() {
        print("VideoManager: User played current video")
        userHasPausedCurrentVideo = false
    }
}

struct Song {
    var artistName: String
    var songDesc: String
    var hashtags: [String]
    var songName: String
}
