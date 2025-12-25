//
//  VideoCell.swift
//  artist discoverer
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
    @State private var likeBurstPulse: Bool = false
    
    private var likeBinding: Binding<Bool> {
        let manager = ActionButtonsManager.shared
        return Binding(
            get: { manager.isLiked(videoId: video.id, feedID: feedID) },
            set: { _ in manager.toggleLike(videoId: video.id) }
        )
    }
    
    private var followBinding: Binding<Bool> {
        let manager = ActionButtonsManager.shared
        return Binding(
            get: { manager.isFollowing(videoId: video.id, feedID: feedID) },
            set: { _ in manager.toggleFollow(artistName: video.artistName) }
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
                    .scaleEffect(likeBurstPulse ? 1.25 : 0.9)
                    .position(tapLocation)
                    .rotationEffect(.degrees(likeBurstPulse ? Double(Int.random(in: -10...10)) : 0))
                    .shadow(color: .black.opacity(0.4), radius: likeBurstPulse ? 14 : 10)
                    .transition(.scale.combined(with: .opacity))
                    .opacity(showLikeBurst ? 1 : 0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: likeBurstPulse)
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
                DispatchQueue.main.async {
                    tapLocation = location
                    showLikeBurst = true
                    likeBurstPulse = true
                    if !video.liked {
                        ActionButtonsManager().toggleLike(videoId: video.id)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        likeBurstPulse = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showLikeBurst = false
                        }
                    }
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

