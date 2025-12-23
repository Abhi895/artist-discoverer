//
//  HomeView.swift
//  artist discoverer
//
//  Main discovery feed - infinite scroll of all videos
//

import SwiftUI
import AVKit

struct HomeView: View {
    @ObservedObject var videoManager = VideoManager.shared
    @State private var currentIndex: Int?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<videoManager.videoURLs.count, id: \.self) { index in
                    
                    VideoView(player: videoManager.getPlayer(at: index) ?? VideoManager.emptyPlayer)
                        .containerRelativeFrame(.vertical)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .onChange(of: currentIndex) { _, newIndex in
            if let newIndex {
                videoManager.onScroll(to: newIndex)
            }
        }
        .ignoresSafeArea(.all)
//        .onAppear {
//            videoManager.onScroll(to: 0)
//        }
    }
}
//
//#Preview {
//    HomeView()
//}
//
