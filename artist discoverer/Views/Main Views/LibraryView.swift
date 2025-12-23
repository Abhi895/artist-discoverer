////
////  LibraryView.swift
////  artist discoverer
////
////  Library tab - Artists and Songs sections
////
//
//import SwiftUI
//import AVKit
//
//struct LibraryView: View {
//    @Binding var selectedTab: Tab
//    @State var artists: Bool = true
//    @ObservedObject private var videoManager = VideoManager.shared
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // Header
//                HStack(alignment: .top) {
//                    Text("Library")
//                        .font(.system(size: 40, weight: .black, design: .default))
//                        .foregroundStyle(.white)
//                    
//                    Spacer()
//                    
//                    Button {
//                        print("SETTINGS")
//                    } label: {
//                        Image(systemName: "line.3.horizontal")
//                            .font(.system(size: 25))
//                    }
//                    .buttonStyle(ShrinkingButton())
//                    .padding(.top, 20)
//                }
//                .padding(.horizontal)
//                
//                // Tab Selector
//                HStack(spacing: 25) {
//                    Button {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            artists = true
//                        }
//                    } label: {
//                        Text("Artists")
//                            .font(.system(size: 17, weight: artists ? .semibold : .regular, design: .rounded))
//                            .foregroundStyle(artists ? Color.appBackground : .white.opacity(0.6))
//                            .padding(.vertical, 6)
//                            .padding(.horizontal, 10)
//                            .background(
//                                Capsule()
//                                    .fill(artists ? .white : .clear)
//                            )
//                    }
//                    
//                    Button {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            artists = false
//                        }
//                        // Pause videos when switching to Songs tab
//                        videoManager.pauseAll()
//                    } label: {
//                        Text("Songs")
//                            .font(.system(size: 17, weight: !artists ? .semibold : .regular, design: .rounded))
//                            .foregroundStyle(!artists ? Color.appBackground : .white.opacity(0.6))
//                            .padding(.vertical, 5)
//                            .padding(.horizontal, 9)
//                            .background(
//                                Capsule()
//                                    .fill(!artists ? .white : .clear)
//                            )
//                    }
//                }
//                .frame(alignment: .center)
//                .padding(.bottom, 10)
//                
//                // Content
//                if artists {
//                    ArtistsView(selectedTab: $selectedTab)
//                } else {
//                    SongsView()
//                }
//            }
//            .frame(maxHeight: .infinity)
//            .background(Color.tabBarBackground)
//            .navigationDestination(for: Int.self) { selectedIndex in
//                // Navigation from SongsView grid
//                SongsVideosView(currentVideoIndex: selectedIndex)
//            }
//        }
//    }
//}
