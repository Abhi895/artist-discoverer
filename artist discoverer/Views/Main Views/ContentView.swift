//
//  ContentView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 28/11/2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var userValid = true
    @State var selectedTab: Tab = .home
    
    @ObservedObject private var videoManager = FeedManager.shared
    let userDefault = UserDefaults.standard
    
    var body: some View {
        ZStack {
            if !userValid {
                LoginView(userValid: $userValid)
            } else {
                VStack(spacing: 0) {
                    
                    Group {
                        switch selectedTab {
                        case .library:
                            LibraryView(selectedTab: $selectedTab)
                                .onDisappear {
                                    videoManager.destroyFeed(id: "artists")
                                    videoManager.destroyFeed(id: "songs")
                                    
                                }
                        case .search:
                            SearchView()
                        case .home:
                            HomeView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
        
        .onChange(of: selectedTab) { _, _ in
            videoManager.pauseAllFeeds()
        }
        
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                videoManager.pauseAllFeeds()
            }
        }
    }
}

// #Preview {
//     ContentView()
// }
