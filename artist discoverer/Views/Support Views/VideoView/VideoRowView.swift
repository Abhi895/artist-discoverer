//
//  VideoRowView.swift
//  artist discoverer
//
//  Simplified - gets player from VideoManager instead of creating its own
//

import SwiftUI
import AVKit

struct VideoView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {

        if uiView.playerLayer.player != player {
            uiView.playerLayer.player = player
        }
    }
}
class PlayerUIView: UIView {
    // Override the backing layer type to be AVPlayerLayer
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    // Helper accessor to avoid casting every time
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
 
