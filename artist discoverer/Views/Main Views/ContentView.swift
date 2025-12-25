//
//  ContentView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 28/11/2025.
//

import SwiftUI

struct ContentView: View {
    // 1. Hook into the App Lifecycle (Active, Background, Inactive)
    @Environment(\.scenePhase) var scenePhase
    
    @State var userValid = true
    @State var selectedTab: Tab = .home
    
    @ObservedObject private var videoManager = VideoManager.shared
    let userDefault = UserDefaults.standard

    var body: some View {
        ZStack {
            if !userValid {
                LoginView(userValid: $userValid)
            } else {
                VStack(spacing: 0) {
                    
                    // 2. Content Area
                    // We use a Group to avoid redundant modifiers
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
        // 3. Handle Tab Switching
        // Whenever we change tabs, pause ALL audio immediately to prevent bleed-over
        .onChange(of: selectedTab) { _, _ in
            videoManager.pauseAllFeeds()
        }
        // 4. Handle App Backgrounding
        // If user swipes up to go home, pause audio immediately
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
