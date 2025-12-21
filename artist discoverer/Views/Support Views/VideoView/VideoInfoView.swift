//
//  VideoInfoView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 16/12/2025.
//

import SwiftUI

struct VideoInfoView: View {
    @ObservedObject private var videoManager = VideoManager.shared
    @State private var offset: Double = 0.0
    let index: Int
    
    private var currentSong: Song? {
        let songs = videoManager.songsInfo
        guard !songs.isEmpty else { return nil }
        let safeIndex = index % songs.count
        return songs[safeIndex]
    }
    
    var body: some View {
        Group {
            if let currentSong {
                SongInfoView(
                    song: currentSong,
                    isCurrent: videoManager.currentPlayingIndex == index,
                    currentFollowing: videoManager.following.contains(currentSong.artistName),
                    offset: $offset
                )
            } else {
                // Fallback when there is no song info available
                VStack { Spacer() }
            }
        }
        .padding(.leading, 15)
        .padding(.bottom, 15)
    }
}

private struct SongInfoView: View {
    let song: Song
    let isCurrent: Bool
    @ObservedObject private var videoManager = VideoManager.shared
    @State var currentFollowing: Bool
    @Binding var offset: Double
    
    @Namespace private var followNamespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .center) {
                        Text(song.artistName)
                            .font(.system(size: 25, weight: .bold, design: .serif))
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                currentFollowing.toggle()
                                if currentFollowing {
                                    videoManager.following.append(song.artistName)
                                } else {
                                    if let index = videoManager.following.firstIndex(of: song.artistName) {
                                        videoManager.following.remove(at: index)
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                // Container that keeps a stable width during morph
                                Group {
                                    if !currentFollowing {
                                        Text("Follow")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 5)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.white)
                                                    .background(Color.clear)
                                            )
                                            .fixedSize(horizontal: true, vertical: true)
                                            .opacity(1)
                                    } else {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.white)
                                            .opacity(1)
                                    }
                                }
                                .frame(minWidth: 70, alignment: .leading) // stabilize width to fit "Follow"
                                .matchedGeometryEffect(id: "followControl", in: followNamespace)
                                .animation(nil, value: currentFollowing) // prevent implicit size animation inside
                            }
                            .contentShape(Rectangle())
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 1.02)),
                                removal: .opacity.combined(with: .scale(scale: 0.98))
                            ))
                        }
                        
                    }
                    .padding(.bottom, 4)
                    
                    
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .frame(width: 14, height: 14)
                        
                        if isCurrent{
                            MarqueeSongText(song: song, offset: $offset)
                        } else {
                            Text("\(song.songName) - \(song.artistName)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .fixedSize()
                                .frame(alignment: .leading)
                        }
                    }
                    
                    Text(song.songDesc)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineLimit(3)
                    
                    FlowLayout(spacing: 5) {
                        ForEach(song.hashtags, id: \.self) { hashtag in
                            Button {
                                print("Hashtag tapped: \(hashtag)")
                            } label: {
                                Text(hashtag)
                                    .font(.system(size: 12, weight: .regular , design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(7)
                                    .glassEffect(.clear)


                            }
                        }
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 250, alignment: .leading)
                .clipped()
                
                Spacer()
            }
        }
    }
}

private struct MarqueeSongText: View {
    let song: Song
    @Binding var offset: Double
    
    private var spacing: Double {
        4 * Double(song.songName.count + song.artistName.count)
    }
    
    var body: some View {
        let display = "\(song.songName) - \(song.artistName)"
        Text(display)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .frame(alignment: .leading)
        //            .lineLimit(1)
            .fixedSize()
            .padding(.trailing, CGFloat(song.songName.count + song.artistName.count))
            .padding(.leading, 5)
            .textRenderer(LoopRenderer(offset: offset, spacing: spacing))
            .onAppear {
                offset = 0
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    withAnimation(.linear(duration: TimeInterval(Double(song.songName.count + song.artistName.count) * 1.7)).repeatForever(autoreverses: false)) {
                        offset = 1
                    }
                }
            }
            .clipped()
            .mask(
                HStack(spacing: 0) {
                    // Left Fade (Transparent -> Black)
                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 10)
                    
                    // Middle (Solid Black = Fully Visible)
                    Rectangle().fill(Color.black)
                    
                    // Right Fade (Black -> Transparent)
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 10) // The length of the fade
                }
            )
    }
}

