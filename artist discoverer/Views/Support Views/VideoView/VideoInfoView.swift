//
//  VideoInfoView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 16/12/2025.
//

import SwiftUI

struct VideoInfoView: View {
    @ObservedObject private var videoManager = VideoManager.shared
    @Binding var following: Bool
    @State private var offset: Double = 0.0
    
    var currVideo: Video?
    var feedID: String // <--- 1. Accept Feed ID
    
    var body: some View {
        Group {
            if let currVideo {
                SongInfoView(
                    video: currVideo,
                    feedID: feedID, // <--- 2. Pass it down
                    offset: $offset,
                    following: $following
                )
            } else {
                VStack { Spacer() }
            }
        }
        .padding(.leading, 15)
        .padding(.bottom, 15)
    }
}

private struct SongInfoView: View {
    let video: Video
    let feedID: String // <--- 3. Accept Feed ID
    
    @ObservedObject private var videoManager = VideoManager.shared
    @Binding var offset: Double
    @Binding var following: Bool
    
    // Computed property to check if THIS video is the one currently playing in THIS feed
    var isCurrentVideo: Bool {
        return videoManager.feeds[feedID]?.currentIndex == video.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .center) {
                        Text(video.artistName)
                            .font(.system(size: 25, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                following.toggle()
                                // TODO: Hook this up to VideoManager.toggleFollow(artistID:) in the future
                            }
                        } label: {
                            ZStack {
                                if !following {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 19))
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 19))
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(ShrinkingButton())
                        }
                    }
                    .padding(.bottom, 4)

                    
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .foregroundStyle(.white)
                            .frame(width: 14, height: 14)
                        
                        // 4. Use the context-aware check for scrolling text
                        if isCurrentVideo {
                            MarqueeSongText(video: video, offset: $offset)
                        } else {
                            Text("\(video.songName) - \(video.artistName)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .fixedSize()
                                .frame(alignment: .leading)
                        }
                    }
                    
                    Text(video.songDesc)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(3)
                    
                    FlowLayout(spacing: 5) {
                        ForEach(video.hashtags, id: \.self) { hashtag in
                            Button {
                                print("Hashtag tapped: \(hashtag)")
                            } label: {
                                Text(hashtag)
                                    .font(.system(size: 11, weight: .regular , design: .monospaced))
                                    .padding(.horizontal, -2)
                                    .padding(.vertical, -1)
                            }
                            .tint(.primary)
                            .buttonStyle(.glass)
                        }
                    }
                }
                .frame(width: 250, alignment: .leading)
                .clipped()
                
                Spacer()
            }
        }
    }
}

// MARK: - Subviews (Unchanged)

private struct MarqueeSongText: View {
    let video: Video
    @Binding var offset: Double
    
    private var spacing: Double {
        3 * Double(video.songName.count + video.artistName.count)
    }
    
    var body: some View {
        let display = "\(video.songName) - \(video.artistName)"
        Text(display)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .frame(alignment: .leading)
            .foregroundStyle(.white)
            .fixedSize()
            .padding(.trailing, CGFloat(video.songName.count + video.artistName.count))
            .padding(.leading, 5)
            .textRenderer(MarqueeRenderer(offset: offset, spacing: spacing))
            .onAppear {
                offset = 0
                // Use a non-blocking task for animation
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    withAnimation(.linear(duration: TimeInterval(Double(video.songName.count + video.artistName.count) * 1.7)).repeatForever(autoreverses: false)) {
                        offset = 1
                    }
                }
            }
            .clipped()
            .mask(
                HStack(spacing: 0) {
                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 10)
                    Rectangle().fill(Color.black)
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 10)
                }
            )
    }
}

struct MarqueeRenderer: TextRenderer {
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
    var spacing: CGFloat = 8

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

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > maxWidth {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        return frames
    }
}
