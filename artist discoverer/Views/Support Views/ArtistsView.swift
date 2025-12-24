//
//  ArtistsView.swift
//  artist discoverer
//
//  Shows followed artists and their latest videos
//

import AVKit
import SwiftUI

struct ArtistsView: View {
    @Binding var selectedTab: Tab
    
    @ObservedObject private var videoManager = VideoManager.shared
    
    var body: some View {
                
        if !videoManager.following.isEmpty {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // Your Artists Section
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("YOUR ARTISTS")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<videoManager.following.count, id: \.self) { i in
                                    VStack(alignment: .center) {
                                        Image(videoManager.following[i].artistName.lowercased())
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .scaledToFit()
                                    }
                                    .padding(.leading)
                                }
                            }
                        }
                    }
                    
                    // Latest Videos Section
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("LATEST VIDEOS")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding([.horizontal, .top])
                        }
                        
                        ArtistsVideosView(selectedTab: $selectedTab)
                    }
                    
                    Spacer()
                }
            }
            
        } else {
            // Empty State
            VStack(spacing: 10) {
                Spacer()
                Image(systemName: "music.mic")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text("You aren't following any artists yet")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text("Follow artists to get updated when they drop new content")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .home
                    }
                } label: {
                    Text("Discover artists")
                        .font(.headline)
                        .frame(width: 200)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                }
                .glassEffect(.clear)
                .padding()
                
                Spacer()
            }
        }
    }
    
}
