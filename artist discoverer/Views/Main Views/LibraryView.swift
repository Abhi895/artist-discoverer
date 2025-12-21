//
//  FavouritesView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import SwiftUI
import AVKit

struct LibraryView: View {
    //    @Binding var selectedTab: Tab
    @State var artists: Bool = true
    
    var body: some View {
        
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
                .padding(.top, 10)
            }.padding()
            
            
            //            HStack(spacing: 15) {
            //                Button {
            //                    withAnimation(.easeInOut(duration: 0.2)) {
            //                        artists = true
            //                    }
            //                } label: {
            //                    Text("Artists")
            //                        .font(.system(size: artists ? 18 : 16, weight: artists ? .semibold: .medium, design: .rounded))
            //                        .foregroundStyle(artists ? .white : .white.opacity(0.6))
            //
            //                }
            //
            //
            //                Button {
            //                    withAnimation(.easeInOut(duration: 0.2)) {
            //                        artists = false
            //                    }
            //                } label: {
            //                    Text("Songs")
            //                        .font(.system(size: !artists ? 18 : 16, weight: !artists ? .semibold: .medium, design: .rounded))
            //                        .foregroundStyle(artists ? .white.opacity(0.6) : .white)
            //                }
            //            }
            //            .frame(alignment: .center)
            //            .padding()
            //
            
            if artists {
                ArtistsView()
            } else {
                Spacer()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            //            Color.tabBarBackground
            
            LinearGradient(colors: [Color.appBackground , Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(.all)
        )
    }
}

//#Preview {
//    FavouritesView()
//}
