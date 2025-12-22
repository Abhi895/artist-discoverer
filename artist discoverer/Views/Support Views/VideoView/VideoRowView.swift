//
//  VideoRowView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 14/12/2025.
//

import SwiftUI
import AVKit

struct VideoRowView: View {
    let url: URL
    let index: Int
    let preview: Bool
    let followingOnly: Bool
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var debugInfo = "Loading..."
    
    @State var liked: Bool = false
    @State private var showLikeBurst = false
    @State private var tapLocation: CGPoint = .init(x: 200, y: 400)
    @State private var likeBurstPulse: Bool = false
    
    @ObservedObject private var videoManager = VideoManager.shared
    
    // --- CHECK: Is this video allowed to play in the current mode? ---
    private var isCorrectModeForPlayback: Bool {
        return preview != videoManager.isFullScreenMode
    }
    
    var body: some View {
                
        ZStack {
            
            if let player = player {
                VideoPlayerView(player: player)
                    .clipped()
            } else {
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
                
                VStack {
                    Text(debugInfo)
                        .foregroundColor(.white)
                        .padding()
                    Text("File: \(url.lastPathComponent)")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Text("Index: \(index)")
                        .foregroundColor(.blue)
                        .font(.caption2)
                }
            }
            
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)

            if !preview {
                VideoInfoView(index: self.index, followingOnly: self.followingOnly)
                ActionButtonsView(liked: $liked)
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
            
            if showPlayButton {
                Button(action: {
                    videoManager.setCurrentPlaying(index: index)
                    videoManager.userPlayedCurrentVideo()
                    playVideo()
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(preview ? .white.opacity(0.5) : .clear, lineWidth: 0.5)
        )
        .onTapGesture {
            if !preview {
                if isPlaying {
                    pauseVideo()
                    videoManager.userPausedCurrentVideo()
                    showPlayButton = true
                } else {
                    videoManager.setCurrentPlaying(index: index)
                    videoManager.userPlayedCurrentVideo()
                    playVideo()
                }
            }
        }
        .onTapGesture(count: 2) {
            
            if !preview {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0.1)) {
                    self.liked = true
                }
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
        .onAppear {
            setupPlayer()
            showPlayButton = false
        }
        .onDisappear {
            player?.pause()
            if !preview {
                 player?.replaceCurrentItem(with: nil)
                 player = nil
            }
        }
        .onChange(of: videoManager.isFullScreenMode) { _, newMode in
            if videoManager.currentPlayingIndex == index {
                if isCorrectModeForPlayback && !videoManager.userHasPausedCurrentVideo {
                    if preview {
                        // Delay to allow full screen exit
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                             if self.videoManager.currentPlayingIndex == self.index
                                && self.isCorrectModeForPlayback
                                && !self.videoManager.userHasPausedCurrentVideo {
                                self.playVideo()
                            }
                        }
                    } else {
                        playVideo()
                    }
                } else {
                    pauseVideo()
                }
            }
        }
        .onChange(of: videoManager.currentPlayingIndex) { oldValue, newValue in
            if newValue == index {
                if !isPlaying && player != nil && !videoManager.userHasPausedCurrentVideo && isCorrectModeForPlayback {
                    playVideo()
                } else if videoManager.userHasPausedCurrentVideo {
                    showPlayButton = true
                }
            } else {
                if isPlaying {
                    pauseVideo()
                }
            }
        }

    }
    
    private func setupPlayer() {
        print("Setting up player for: \(url.lastPathComponent) at index \(index)")
        debugInfo = "Loading..."
        
        let asset = AVURLAsset(url: url)
        
        Task {
            let finalItem: AVPlayerItem
            
            if preview {
                // --- STRICT AUDIO STRIPPING ---
                // We create a new empty composition (No audio tracks exist here)
                let composition = AVMutableComposition()
                
                do {
                    // 1. Load video tracks from source
                    let tracks = try await asset.load(.tracks)
                    let videoTracks = tracks.filter { $0.mediaType == .video }
                    
                    if let sourceVideoTrack = videoTracks.first {
                        // 2. Create a video track in the composition
                        let compVideoTrack = composition.addMutableTrack(
                            withMediaType: .video,
                            preferredTrackID: kCMPersistentTrackID_Invalid
                        )
                        
                        // 3. Insert the source video range into the composition
                        // Using the track's timeRange ensures we match the video content exactly
                        let timeRange = try await sourceVideoTrack.load(.timeRange)
                        try compVideoTrack?.insertTimeRange(timeRange, of: sourceVideoTrack, at: .zero)
                        
                        // 4. Orientation Fix (Important for composition)
                        let transform = try await sourceVideoTrack.load(.preferredTransform)
                        compVideoTrack?.preferredTransform = transform
                        
                        // Success: We use the stripped composition
                        finalItem = AVPlayerItem(asset: composition)
                    } else {
                        // No video track found? Return empty item (Silent)
                        print("Error: No video track found for preview stripping")
                        return
                    }
                } catch {
                    print("Error stripping audio: \(error)")
                    return // Stop setup on error to prevent audio leak
                }
                
            } else {
                // Not a preview: Use original asset
                finalItem = AVPlayerItem(asset: asset)
            }
            
            // Assign to Main Actor
            await MainActor.run {
                let newPlayer = AVPlayer(playerItem: finalItem)
                newPlayer.actionAtItemEnd = .none
                
                // Mute settings just in case
                newPlayer.isMuted = preview
                newPlayer.volume = preview ? 0 : 1
                
                // Only assign player NOW, after all processing is done
                self.player = newPlayer
                debugInfo = "Ready"
                
                // Auto-play check
                if videoManager.currentPlayingIndex == index
                    && !videoManager.userHasPausedCurrentVideo
                    && isCorrectModeForPlayback {
                    playVideo()
                }
                
                // Loop Logic
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: finalItem,
                    queue: .main
                ) { _ in
                    finalItem.seek(to: .zero, completionHandler: nil)
                }
            }
        }
    }
    
    private func playVideo() {
        guard let player = player else { return }
        
        if !isCorrectModeForPlayback { return }
        
        // Ensure volume settings are correct before playing
        player.isMuted = preview
        player.volume = preview ? 0 : 1.0
        
        player.play()
        isPlaying = true
        showPlayButton = false
    }
    
    private func pauseVideo() {
        guard let player = player else { return }
        player.pause()
        isPlaying = false
    }
}
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        let view = VideoPlayerUIView()
        view.player = player
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        uiView.player = player
    }
}

final class VideoPlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}

