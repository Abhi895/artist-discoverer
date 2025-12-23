////
////  VideoInfoView.swift
////  artist discoverer
////
////  Created by Abhi Reddy on 16/12/2025.
////
//
//import SwiftUI
//
//struct VideoInfoView: View {
//    @ObservedObject private var videoManager = VideoManager.shared
//    @State private var offset: Double = 0.0
//    let index: Int
//    let followingOnly: Bool
//    
//    private var currentSong: Song? {
//        let songs = followingOnly ? videoManager.following : videoManager.songsInfo
//        guard !songs.isEmpty else { return nil }
//        let safeIndex = index % songs.count
//        return songs[safeIndex]
//    }
//    
//    var body: some View {
//        Group {
//            if let currentSong {
//                SongInfoView(
//                    song: currentSong,
//                    isCurrent: videoManager.currentPlayingIndex == index,
//                    currentFollowing: videoManager.following.contains(where: { $0.artistName == currentSong.artistName && $0.songName == currentSong.songName }),
//                    offset: $offset
//                )
//            } else {
//                VStack { Spacer() }
//            }
//        }
//        .padding(.leading, 15)
//        .padding(.bottom, 15)
//    }
//}
//
//private struct SongInfoView: View {
//    let song: Song
//    let isCurrent: Bool
//    @ObservedObject private var videoManager = VideoManager.shared
//    @State var currentFollowing: Bool
//    @Binding var offset: Double
//    
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Spacer()
//            HStack {
//                VStack(alignment: .leading, spacing: 9) {
//                    HStack(alignment: .center) {
//                        Text(song.artistName)
//                            .font(.system(size: 25, weight: .bold, design: .serif))
//                            .foregroundStyle(.white)
//                            .minimumScaleFactor(0.8)
//                            .lineLimit(1)
//                        
//                        Button {
//                            withAnimation(.easeInOut(duration: 0.2)) {
//                                currentFollowing.toggle()
//                                if currentFollowing {
//                                    videoManager.following.append(song)
//                                } else {
//                                    if let index = videoManager.following.firstIndex(where: { $0.artistName == song.artistName && $0.songName == song.songName }) {
//                                        videoManager.following.remove(at: index)
//                                    }
//                                }
//                            }
//                        } label: {
//                            ZStack {
//                                if !currentFollowing {
//                                    Image(systemName: "plus.circle")
//                                        .font(.system(size: 19))
//                                        .foregroundStyle(.white)
//                                        .opacity(1)
//                                } else {
//                                    Image(systemName: "checkmark.circle")
//                                        .font(.system(size: 19))
//                                        .foregroundStyle(.white)
//                                        .opacity(1)
//                                }
//                            }
//                        }
//                        .buttonStyle(ShrinkingButton())
//                        
//                    }
//                    .padding(.bottom, 4)
//                    
//                    
//                    HStack(spacing: 8) {
//                        Image(systemName: "waveform")
//                            .foregroundStyle(.white)
//                            .frame(width: 14, height: 14)
//                        
//                        if isCurrent{
//                            MarqueeSongText(song: song, offset: $offset)
//                        } else {
//                            Text("\(song.songName) - \(song.artistName)")
//                                .font(.system(size: 14, weight: .bold, design: .rounded))
//                                .foregroundStyle(.white)
//                                .fixedSize()
//                                .frame(alignment: .leading)
//                        }
//                    }
//                    
//                    Text(song.songDesc)
//                        .foregroundStyle(.white)
//                        .font(.system(size: 14, weight: .regular, design: .rounded))
//                        .lineLimit(3)
//                    
//                    FlowLayout(spacing: 5) {
//                        ForEach(song.hashtags, id: \.self) { hashtag in
//                            Button {
//                                print("Hashtag tapped: \(hashtag)")
//                            } label: {
//                                Text(hashtag)
//                                    .font(.system(size: 11, weight: .regular , design: .monospaced))
//                                    .padding(.horizontal, -2)
//                                    .padding(.vertical, -1)
//
//
//                            }
//                            .tint(.primary)
//                            .buttonStyle(.glass)
//                        }
//                    }
//                }
////                .foregroundStyle(.white)
//                .frame(width: 250, alignment: .leading)
//                .clipped()
//                
//                Spacer()
//            }
//        }
//    }
//}
//
//private struct MarqueeSongText: View {
//    let song: Song
//    @Binding var offset: Double
//    
//    private var spacing: Double {
//        3 * Double(song.songName.count + song.artistName.count)
//    }
//    
//    var body: some View {
//        let display = "\(song.songName) - \(song.artistName)"
//        Text(display)
//            .font(.system(size: 14, weight: .bold, design: .rounded))
//            .frame(alignment: .leading)
//            .foregroundStyle(.white)
//        //            .lineLimit(1)
//            .fixedSize()
//            .padding(.trailing, CGFloat(song.songName.count + song.artistName.count))
//            .padding(.leading, 5)
//            .textRenderer(MarqueeRenderer(offset: offset, spacing: spacing))
//            .onAppear {
//                offset = 0
//                Task { @MainActor in
//                    try? await Task.sleep(nanoseconds: 1_500_000_000)
//                    withAnimation(.linear(duration: TimeInterval(Double(song.songName.count + song.artistName.count) * 1.7)).repeatForever(autoreverses: false)) {
//                        offset = 1
//                    }
//                }
//            }
//            .clipped()
//            .mask(
//                HStack(spacing: 0) {
//                    // Left Fade (Transparent -> Black)
//                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
//                        .frame(width: 10)
//                    
//                    // Middle (Solid Black = Fully Visible)
//                    Rectangle().fill(Color.black)
//                    
//                    // Right Fade (Black -> Transparent)
//                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .leading, endPoint: .trailing)
//                        .frame(width: 10) // The length of the fade
//                }
//            )
//    }
//}
//
//
//struct MarqueeRenderer: TextRenderer {
//    var offset: Double
//    var spacing: Double = 20
//    
//    var animatableData: Double {
//        get { offset }
//        set { offset = newValue }
//    }
//    
//    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
//        for line in layout {
//            let cycleDistance = line.typographicBounds.width + spacing
//            
//            let moveAmount = offset * cycleDistance
//            
//            
//            var main = context
//            main.translateBy(x: moveAmount, y: 0)
//            main.draw(line)
//            
//            
//            var ghost = context
//            ghost.translateBy(x: moveAmount - cycleDistance, y: 0)
//            ghost.draw(line)
//        }
//    }
//}
//
//struct FlowLayout: Layout {
//    var spacing: CGFloat = 8 // Gap between items
//
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let frames = arrangeSubviews(proposal: proposal, subviews: subviews)
//        let width = frames.map { $0.maxX }.max() ?? 0
//        let height = frames.map { $0.maxY }.max() ?? 0
//        return CGSize(width: width, height: height)
//    }
//
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        let frames = arrangeSubviews(proposal: proposal, subviews: subviews)
//        for (index, frame) in frames.enumerated() {
//            guard index < subviews.count else { break }
//            let origin = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
//            subviews[index].place(at: origin, proposal: ProposedViewSize(width: frame.width, height: frame.height))
//        }
//    }
//
//    // Helper to calculate positions
//    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
//        var frames: [CGRect] = []
//        var x: CGFloat = 0
//        var y: CGFloat = 0
//        var maxHeight: CGFloat = 0
//        let maxWidth = proposal.width ?? .infinity
//
//        for view in subviews {
//            let size = view.sizeThatFits(.unspecified)
//            
//            // If this item pushes past the edge, move to next line (reset X, increase Y)
//            if x + size.width > maxWidth {
//                x = 0
//                y += maxHeight + spacing
//                maxHeight = 0
//            }
//            
//            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
//            
//            // Advance X pointer for the next item
//            x += size.width + spacing
//            maxHeight = max(maxHeight, size.height)
//        }
//        return frames
//    }
//}
