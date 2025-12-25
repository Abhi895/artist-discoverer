//
//  FeedContext.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 25/12/2025.
//

import SwiftUI
import AVKit

struct FeedContext {
    var id: String = ""
    var videos: [Video] = []
    var players: [Int: AVQueuePlayer] = [:] 
    var loopers: [Int: AVPlayerLooper] = [:]
    var currentIndex: Int = 0
    var loadingTasks: [Int: Task<Void, Never>] = [:]
}
