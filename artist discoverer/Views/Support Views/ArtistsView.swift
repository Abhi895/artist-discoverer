//
//  ArtistsView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 17/12/2025.
//

import AVKit
import SwiftUI

struct ArtistsView: View {
    //    @Binding var selectedTab: Tab
    
    @State private var currentVideoIndex = 0
    @ObservedObject private var videoManager = VideoManager.shared
    @State var noFavourites: Bool = true
    @State private var showEmptyState: Bool = false
    
    private var videoURLs: [URL] {
        var urls: [URL] = []
        
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            for url in videosFromRoot {
                for aristName in videoManager.following {
                    if url.lastPathComponent.contains(aristName) {
                        urls.append(url)
                    }
                }
            }
        }
        
        
        print("Found \(urls.count) video files:")
        for url in urls {
            print("  - \(url.lastPathComponent) at \(url.path)")
        }
        
        // If no videos found, add a sample remote video for testing
        
        return urls
    }
    
    // Create infinite loop of videos
    private var infiniteVideoURLs: [URL] {
        guard !videoURLs.isEmpty else { return [] }
        // Repeat the video array multiple times for infinite scrolling effect
        return Array(repeating: videoURLs, count: 1000).flatMap { $0 }
    }
    
    //    init(selectedTab: Binding<Tab>) {
    //        UITabBar.appearance().isHidden = true
    //        self._selectedTab = selectedTab
    //    }
    //
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        Text("Your Artists")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<videoManager.songsInfo.count, id: \.self) { i in
                                VStack(alignment: .center) {
                                    Image(videoManager.songsInfo[i].artistName.lowercased())
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .scaledToFit()
                                        .overlay(
                                            Circle()
                                                .fill(.clear)
                                                .stroke(.white)
                                        )
                                    
                                    Text("\(videoManager.songsInfo[i].artistName)")
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }.padding(.leading)
                            }
                            
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Latest Videos")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<videoManager.songsInfo.count, id: \.self) { i in
                                
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .overlay(
                                            LinearGradient(colors: [Color.clear, Color.black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                        )
                                    
                                    VStack (alignment: .leading) {
                                        Spacer()
                                        HStack(alignment: .center) {
                                            Image(videoManager.songsInfo[i].artistName.lowercased())
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .scaledToFit()
                                                .overlay(
                                                    Circle()
                                                        .fill(.clear)
                                                        .stroke(.white)
                                                )
                                            
                                            Text("\(videoManager.songsInfo[i].artistName)")
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            
                                            
                                            Spacer()
                                            
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 5)
                                    }
                                    
                                }
                                .frame(width: 180, height: 250)
                                .padding(.leading)
                                
                                
                                
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        //                        Image(systemName: "music.mic")
        //                            .font(.system(size: 56, weight: .semibold))
        //                            .foregroundStyle(.white.opacity(0.7))
        //                        Text("You aren't following any artists yet")
        //                            .font(.title3.weight(.semibold))
        //                            .multilineTextAlignment(.center)
        //                            .foregroundStyle(.white)
        //                        Text("Follow artists to get updated when they drop new content")
        //                            .font(.footnote)
        //                            .multilineTextAlignment(.center)
        //                            .foregroundStyle(.white.opacity(0.7))
        //                        Button {
        //                            selectedTab = .home
        //
        //                        } label: {
        //                            Text("Discover artists")
        //                                .font(.headline)
        //                                .frame(width: 200)
        //                                .padding(.vertical, 12)
        //                                .foregroundStyle(.white)
        //                        }
        //                        .glassEffect(.clear)
        //                    .padding()
        //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
        //                    .background(
        //                        LinearGradient(colors: [Color.appBackground , Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
        //                            .ignoresSafeArea(.all)
        //                    )
        //                } else {
        //                    ScrollViewReader { proxy in
        //                        ScrollView {
        //                            LazyVStack(spacing: 0) {
        //                                ForEach(Array(infiniteVideoURLs.enumerated()), id: \.offset) { index, url in
        //                                    VideoRowView(url: url, index: index)
        //                                        .containerRelativeFrame([.horizontal, .vertical])
        //                                        .id(index)
        //                                }
        //                            }
        //                            .scrollTargetLayout()
        //                        }
        //                        .scrollTargetBehavior(.paging)
        //                        .scrollIndicators(.hidden)
        //                        .scrollPosition(id: .init(get: {
        //                            videoManager.scrollPosition
        //                        }, set: { newValue in
        //                            if let newIndex = newValue {
        //                                print("Scroll position changed to: \(newIndex)")
        //                                currentVideoIndex = newIndex
        //                                videoManager.setCurrentPlaying(index: newIndex)
        //                            }
        //                        }))
        //                        .ignoresSafeArea(.container, edges: .top)
        //                    }
        //                    .onAppear {
        //                        // Reset to current video when returning to discover tab
        //                        print("Discover view appeared, resetting to current video: \(currentVideoIndex)")
        //                        videoManager.resetToIndex(currentVideoIndex)
        //                    }
        //                }
        //            }
        //
        //        }
        //        .ignoresSafeArea(.keyboard)
        //        .task {
        //            // Configure audio session for video playback
        //            try? AVAudioSession.sharedInstance().setCategory(
        //                .playback,
        //                mode: .moviePlayback,
        //                options: [.allowAirPlay, .allowBluetoothA2DP]
        //            )
        //            try? AVAudioSession.sharedInstance().setActive(true)
        //
        //            // Initialize the first video
        //            if selectedTab == .home {
        //                print("Initializing first video at index 0")
        //                videoManager.setCurrentPlaying(index: 0)
        //            }
        //        }
    }
}

//#Preview {
//    ArtistsView()
//}

