//
//  ContentView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 28/11/2025.
//

import SwiftUI

struct ContentView: View {
    @State var userValid = true
    @State var selectedTab: Tab = .home
    
    //    @ObservedObject private var videoManager = VideoManager.shared
    
    var body: some View {
        ZStack {
            //            if !userValid {
            //                LoginView(userValid: $userValid)
            //            } else {
            VStack(spacing: 0) {
                //                    switch selectedTab {
                //                    case .library:
                //                        LibraryView(selectedTab: $selectedTab)
                //                            .onAppear {
                //                                // Pause all videos when switching to other tabs
                //                                videoManager.pauseAllVideos()
                //                            }
                //                    case .search:
                //                        SearchView()
                //                            .onAppear {
                //                                // Pause all videos when switching to other tabs
                //                                videoManager.pauseAllVideos()
                //                            }
                //                    default:
                HomeView()
                
                //                    }
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    ContentView()
}
