//
//  FeedContext.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 25/12/2025.
//

import SwiftUI
import AVKit

struct FeedContext {
    var id: String
    var videos: [Video] = []
    var players: [Int: AVQueuePlayer] = [:] // Isolated players
    var loopers: [Int: AVPlayerLooper] = [:] // Isolated loopers
    var currentIndex: Int = 0
    var paused: Bool = false
}
