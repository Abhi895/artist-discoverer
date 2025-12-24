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
    
    @ObservedObject private var videoManager = VideoManager.shared
    let userDefault = UserDefaults.standard

    var body: some View {
        ZStack {
            if !userValid {
                LoginView(userValid: $userValid)
            } else {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .library:
                        LibraryView(selectedTab: $selectedTab)
                            .onAppear {
                                videoManager.pauseAllVideos()
                            }
                    case .search:
                        SearchView()
                            .onAppear {
                            }
                    default:
                        HomeView()
                            .onAppear() {
                                videoManager.pauseAllVideos()
                            }
                    }
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}
    
//    #Preview {
//        ContentView()
//    }
