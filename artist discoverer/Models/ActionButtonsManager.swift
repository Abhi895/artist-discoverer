//
//  ActionButtonsManager.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 25/12/2025.
//

import SwiftUI
import AVKit

struct ActionButtonsManager {
    
    @ObservedObject var videoManager = FeedManager.shared
        
    func toggleLike(videoId: Int) {
        if let idx = videoManager.masterVideos.firstIndex(where: { $0.id == videoId }) {
            videoManager.masterVideos[idx].liked.toggle()
        }
        
        for (feedID, var context) in videoManager.feeds {
            if let index = context.videos.firstIndex(where: { $0.id == videoId }) {
                context.videos[index].liked.toggle()
                videoManager.feeds[feedID] = context // Publish change
            }
        }
    }
    
    func toggleFollow(artistName: String) {
        for i in 0..<videoManager.masterVideos.count {
            if videoManager.masterVideos[i].artistName == artistName {
                videoManager.masterVideos[i].followingArtist.toggle()
            }
        }
        
        for (feedID, var context) in videoManager.feeds {
            var feedUpdated = false
            for i in 0..<context.videos.count {
                if context.videos[i].artistName == artistName {
                    context.videos[i].followingArtist.toggle()
                    feedUpdated = true
                }
            }
            if feedUpdated { videoManager.feeds[feedID] = context }
        }
    }
    
    func isLiked(videoId: Int, feedID: String) -> Bool {
        return videoManager.feeds[feedID]?.videos.first(where: { $0.id == videoId })?.liked ?? false
    }
    
    func isFollowing(videoId: Int, feedID: String) -> Bool {
        return videoManager.feeds[feedID]?.videos.first(where: { $0.id == videoId })?.followingArtist ?? false
    }
    
}
