//
//  LibraryView.swift
//  artist discoverer
//
//  Library tab - Artists and Songs sections
//

import SwiftUI
import AVKit

struct LibraryView: View {
    @Binding var selectedTab: Tab
    @State var artists: Bool = true
    @ObservedObject private var videoManager = VideoManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .top) {
                    Text("Library")
                        .font(.system(size: 40, weight: .black, design: .default))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        print("SETTINGS")
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 25))
                    }
                    .buttonStyle(ShrinkingButton())
                    .padding(.top, 20)
                }
                .padding([.horizontal, .top])
                
                HStack(spacing: 25) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            artists = true
                        }
                    } label: {
                        Text("Artists")
                            .font(.system(size: 17, weight: artists ? .semibold : .regular, design: .rounded))
                            .foregroundStyle(artists ? Color.appBackground : .white.opacity(0.6))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule()
                                    .fill(artists ? .white : .clear)
                            )
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            artists = false
                        }
                    } label: {
                        Text("Songs")
                            .font(.system(size: 17, weight: !artists ? .semibold : .regular, design: .rounded))
                            .foregroundStyle(!artists ? Color.appBackground : .white.opacity(0.6))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 9)
                            .background(
                                Capsule()
                                    .fill(!artists ? .white : .clear)
                            )
                    }
                }
                .frame(alignment: .center)
                .padding(.bottom, 10)
                
                // Content
                if artists {
                    ArtistsView(selectedTab: $selectedTab)
                        .onAppear {
                            videoManager.useFollowing = true
//                            videoManager.resetFeed(newIndex: 0)
                            videoManager.following = videoManager.videos.filter(\.followingArtist)
                        }
                        .onDisappear {
                            videoManager.useFollowing = false

                        }
                } else {
                    SongsView()
                    
                }

            }
            .frame(maxHeight: .infinity)
            .background(Color.tabBarBackground)
            .navigationDestination(for: ActiveVideos.self) { ActiveVideo in
                // Navigation from SongsView grid
                SongsVideosView(activeVideos: ActiveVideo)
            }
        }
    }
}
