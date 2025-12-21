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
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showPlayButton = false
    @State private var debugInfo = "Loading..."
    
    @State var liked: Bool = false
    @State private var showLikeBurst = false
    @State private var tapLocation: CGPoint = .init(x: 200, y: 400)
    @State private var likeBurstPulse: Bool = false
    
    @ObservedObject private var videoManager = VideoManager.shared
    
    var body: some View {
                
        ZStack {
            
            if let player = player {
                VideoPlayerView(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
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
            
            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            
            VideoInfoView(index: self.index)
            ActionButtonsView(liked: $liked)
            
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
                    // When manually playing via button, set this as current and play
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
        .contentShape(Rectangle())
        .onTapGesture {
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
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0.1)) {
                self.liked = true
            }
            // Trigger burst at last tap location
            showLikeBurst = true
            likeBurstPulse = true
            // Reset pulse so it can be retriggered
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                likeBurstPulse = false
            }
            // Fade out after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showLikeBurst = false
                }
            }
        }
        .onAppear {
            setupPlayer()
            showPlayButton = false
            if videoManager.currentPlayingIndex == 0 && !videoManager.userHasPausedCurrentVideo {
                playVideo()
            }
        }
        .onDisappear {
            pauseVideo()
        }
        .onChange(of: videoManager.currentPlayingIndex) { oldValue, newValue in
            print("Video \(index): VideoManager index changed from \(oldValue) to \(newValue)")
            
            if newValue == index {
                if !isPlaying && player != nil && !videoManager.userHasPausedCurrentVideo {
                    print("Video \(index): Starting playback because this is current and user hasn't paused")
                    playVideo()
                } else if videoManager.userHasPausedCurrentVideo {
                    print("Video \(index): Not auto-playing because user paused this video")
                    showPlayButton = true
                }
            } else {
                // This video should be paused (either different video or pause all)
                if isPlaying {
                    print("Video \(index): Pausing because current is \(newValue)")
                    pauseVideo()
                    // Don't show button here - let user interaction control button visibility
                }
            }
        }

    }
    
    private func setupPlayer() {
        print("Setting up player for: \(url.lastPathComponent) at index \(index)")
        print("Full URL: \(url)")
        debugInfo = "Setting up player..."
        
        // Check if file exists (for bundled files)
        if url.isFileURL {
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("File exists: \(fileExists)")
            if !fileExists {
                debugInfo = "File not found: \(url.lastPathComponent)"
                return
            }
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        
        debugInfo = "Player created, checking status..."
        
        Task {
            //            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                if let player = player {
                    let status = player.currentItem?.status
                    switch status {
                    case .readyToPlay:
                        debugInfo = "Ready to play!"
                        // Only start playing if this is the current video and user hasn't paused it
                        if videoManager.currentPlayingIndex == index && !videoManager.userHasPausedCurrentVideo {
                            print("Auto-playing video at index \(index) because it's current and user hasn't paused")
                            playVideo()
                        } else {
                            print("Not auto-playing video at index \(index) because current is \(videoManager.currentPlayingIndex) or user paused it")
                            if videoManager.userHasPausedCurrentVideo && videoManager.currentPlayingIndex == index {
                                // Show play button if user paused this video
                                showPlayButton = true
                            }
                        }
                    case .failed:
                        debugInfo = "Failed to load: \(player.currentItem?.error?.localizedDescription ?? "Unknown error")"
                        print("Player failed: \(player.currentItem?.error?.localizedDescription ?? "Unknown")")
                    case .unknown:
                        debugInfo = "Status unknown"
                    case .none:
                        debugInfo = "No player item"
                    @unknown default:
                        debugInfo = "Unknown status"
                    }
                }
            }
        }
        
        // Loop the video when it ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("Video ended, looping: \(url.lastPathComponent)")
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }
    
    private func playVideo() {
        guard let player = player else {
            debugInfo = "No player available"
            return
        }
        print("Starting playback for: \(url.lastPathComponent) at index \(index)")
        debugInfo = "Playing..."
        player.isMuted = false // Unmute when playing
        player.play()
        isPlaying = true
        
        // Always hide play button when video starts playing
        showPlayButton = false
        
    }
    
    private func pauseVideo() {
        guard let player = player else { return }
        print("Pausing video: \(url.lastPathComponent) at index \(index)")
        debugInfo = "Paused"
        player.pause()
        player.isMuted = true // Mute when paused
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


struct LoopRenderer: TextRenderer {
    var offset: Double
    var spacing: Double = 20
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            let cycleDistance = line.typographicBounds.width + spacing
            
            let moveAmount = offset * cycleDistance
            
            
            var main = context
            main.translateBy(x: moveAmount, y: 0)
            main.draw(line)
            
            
            var ghost = context
            ghost.translateBy(x: moveAmount - cycleDistance, y: 0)
            ghost.draw(line)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8 // Gap between items

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let frames = arrangeSubviews(proposal: proposal, subviews: subviews)
        let width = frames.map { $0.maxX }.max() ?? 0
        let height = frames.map { $0.maxY }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in frames.enumerated() {
            guard index < subviews.count else { break }
            let origin = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
            subviews[index].place(at: origin, proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
    }

    // Helper to calculate positions
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            // If this item pushes past the edge, move to next line (reset X, increase Y)
            if x + size.width > maxWidth {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            
            // Advance X pointer for the next item
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        return frames
    }
}

