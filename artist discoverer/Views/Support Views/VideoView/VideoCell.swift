//
//  VideoCell.swift
//  artist discoverer
//
//  Simplified - gets player from VideoManager instead of creating its own
//

import SwiftUI
import AVKit


struct VideoCell: View {
    let index: Int
    let video: Video
    let feedID: String // <--- Scalable ID
    let preview: Bool  // Added this missing prop from your code
    
    @ObservedObject var videoManager = FeedManager.shared
    @State private var showLikeBurst = false
    @State private var tapLocation: CGPoint = .zero
    
    // The Binding that syncs everything
    private var likeBinding: Binding<Bool> {
        Binding(
            get: { ActionButtonsManager().isLiked(videoId: video.id, feedID: feedID) },
            set: { _ in ActionButtonsManager().toggleLike(videoId: video.id) }
        )
    }
    
    private var followBinding: Binding<Bool> {
        Binding(
            get: { ActionButtonsManager().isFollowing(videoId: video.id, feedID: feedID) },
            set: { _ in ActionButtonsManager().toggleFollow(artistName: video.artistName) }
        )
    }
    
    var body: some View {
        ZStack {
            Color.black
            
            // 1. Only get player for THIS feed
            if let player = videoManager.getPlayer(feedID: feedID, index: index) {
                VideoView(player: player)
            }
            
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            
            if !preview {
                // 2. Pass the syncing binding
                ActionButtonsView(liked: likeBinding)
                VideoInfoView(following: followBinding, currVideo: video, feedID: feedID)
            }
            
            if showLikeBurst {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.red)
                    .position(tapLocation)
            }
            
            if video.paused && !preview {
                Image(systemName: "play.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: .black, radius: 12, y: 4)
            }
        }
        .onTapGesture {
            if !preview { videoManager.togglePlay(feedID: feedID, index: index) }
        }
        .onTapGesture(count: 2) { location in
            if !preview {
                tapLocation = location
                withAnimation {
                    if !video.liked {
                        ActionButtonsManager().toggleLike(videoId: video.id)
                    }
                    showLikeBurst = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation { showLikeBurst = false }
                }
            }
        }
    }
}


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

