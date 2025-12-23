//
//  VideoRowView.swift
//  artist discoverer
//
//  Simplified - gets player from VideoManager instead of creating its own
//

import SwiftUI
import AVKit

struct VideoCell: View {
    let index: Int
    let video: Video
    
    @State private var showLikeBurst = false
    @State private var tapLocation: CGPoint = .init(x: 200, y: 400)
    @State private var likeBurstPulse: Bool = false
        
    @ObservedObject var videoManager = VideoManager.shared
    
    private static let gradient = LinearGradient(
        colors: [.clear, .black.opacity(0.6)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ZStack {
            Color.black
            
            if let player = videoManager.players[index] {
                VideoView(player: player)
            }
            
            Self.gradient
            
            if videoManager.paused {
                Image(systemName: "play.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: .black, radius: 12, y: 4)
            }
            
            if showLikeBurst {
                 Image(systemName: "heart.fill")
                     .font(.system(size: 120))
                     .foregroundStyle(.red)
                     .scaleEffect(likeBurstPulse ? 1.25 : 0.9)
                     .rotationEffect(.degrees(likeBurstPulse ? Double(Int.random(in: -10...10)) : 0))
                     .shadow(color: .black.opacity(0.4), radius: likeBurstPulse ? 14 : 10)
                     .position(tapLocation)
                     .transition(.scale.combined(with: .opacity))
                     .opacity(showLikeBurst ? 1 : 0)
                     .animation(.spring(response: 0.25, dampingFraction: 0.6), value: likeBurstPulse)
             }
            
            ActionButtonsView(liked: $videoManager.videos[index].liked)

            VideoInfoView(currVideo: video)
//                .padding(.bottomLeading, 5)

        }
        .onTapGesture {
            print(index)
            videoManager.togglePlay(at: index)
        }
        .onTapGesture(count: 2) {
            // Ensure baseline state before animating in
            showLikeBurst = false
            likeBurstPulse = false

            withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0.1)) {
                videoManager.videos[index].liked = true
            }

            // Defer turning the burst on to the next run loop for reliable first-time animation
            DispatchQueue.main.async {
                showLikeBurst = true
                likeBurstPulse = true

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

