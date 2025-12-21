//
//  FavouritesView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import SwiftUI
import AVKit

struct LibraryView: View {
    @Binding var selectedTab: Tab
    @State var artists: Bool = true

    var body: some View {
        
        ZStack {
            if artists {
                ArtistsView(selectedTab: $selectedTab)
            }
            
            VStack {
            
                HStack(spacing: 15) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            artists = true
                        }
                    } label: {
                        Text("Artists")
                            .font(.system(size: artists ? 18 : 16, weight: artists ? .semibold: .medium, design: .rounded))
                            .foregroundStyle(artists ? .white : .white.opacity(0.6))
                        
                    }
                    
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            artists = false
                        }
                    } label: {
                        Text("Songs")
                            .font(.system(size: !artists ? 18 : 16, weight: !artists ? .semibold: .medium, design: .rounded))
                            .foregroundStyle(artists ? .white.opacity(0.6) : .white)
                    }
                }
                .frame(alignment: .center)
                .padding()
                
                Spacer()

            }
        }
    }
}

//#Preview {
//    FavouritesView()
//}
