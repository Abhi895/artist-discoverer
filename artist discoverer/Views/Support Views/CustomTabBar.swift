//
//  CustomTabBar.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @State var width = 0.0;
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Rectangle()
                .fill(.white.opacity(0.7))
                .frame(height: 0.3)
            
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
                                .font(.system(size: 22)) // Icon size
                            // Make the icon filled if selected, outline if not (optional polish)
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                            
                            Text(tab.rawValue)
                                .font(.system(size: 12))
                            
                        }
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                    }
                    
                    Spacer()
                }
            }
            
            .padding(.top, 9)
            .padding(.bottom, 7)
            .padding(.horizontal, 5)
            .background(Color.tabBarBackground)
        }
    }
}


extension Color {
    static let appBackground = Color(red: 0.047, green: 0.169, blue: 0.306) // Your Cobalt Blue
    static let tabBarBackground = Color(red: 0, green: 0, blue: 0.05) // A darker shade for the footer
}

// 2. Define the Tab cases
enum Tab: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case library = "Library"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical"
        }
    }
}
