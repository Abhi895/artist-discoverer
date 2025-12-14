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
    
    private init() {}
    
    func setCurrentPlaying(index: Int) {
        print("VideoManager: Setting current playing to index \(index)")
        currentPlayingIndex = index
        scrollPosition = index
        userHasPausedCurrentVideo = false // Reset pause state for new video
    }
    
    func pauseAllVideos() {
        print("VideoManager: Pausing all videos")
        currentPlayingIndex = -1 // Set to invalid index to pause all
    }
    
    func resetToIndex(_ index: Int) {
        print("VideoManager: Resetting to index \(index)")
        currentPlayingIndex = index
        scrollPosition = index
        // Don't reset userHasPausedCurrentVideo here - preserve user's pause intention
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
