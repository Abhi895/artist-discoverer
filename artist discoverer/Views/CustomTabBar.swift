//
//  CustomTabBar.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .frame(height: 0.2)
            
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    
                    Button(action: {
                        // Add a small animation when switching
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 24)) // Icon size
                            // Make the icon filled if selected, outline if not (optional polish)
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                            
                        }
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                    }
                    
                    Spacer()
                }
            }
            
            .padding(.top, 14)
            .padding(.bottom, 14)
            .padding(.horizontal, 5)
            .background(Color.tabBarBackground)
        }
    }
}


extension Color {
    static let appBackground = Color(red: 0.047, green: 0.169, blue: 0.306) // Your Cobalt Blue
    static let tabBarBackground = Color.black // A darker shade for the footer
}

// 2. Define the Tab cases
enum Tab: String, CaseIterable {
    case favourites = "Favourites"
    case discover = "Discover"
    case search = "Search"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .favourites: return "star"
        case .discover: return "music.note"
        case .search: return "magnifyingglass"
        case .profile: return "person.crop.circle"
        }
    }
}
