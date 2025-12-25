import SwiftUI
import AVKit

struct LibraryView: View {
    @Binding var selectedTab: Tab
    @State var artists: Bool = true
    
    // but useful if we want to pre-fetch generic data.
    @ObservedObject private var feedManager = FeedManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                // --- Header ---
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
                    .padding(.top, 20)
                }
                .padding([.horizontal, .top])
                
                // --- Toggle Switch (Artists / Songs) ---
                HStack(spacing: 25) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { artists = true }
                    } label: {
                        Text("Artists")
                            .font(.system(size: 17, weight: artists ? .semibold : .regular, design: .rounded))
                            .foregroundStyle(artists ? Color.appBackground : .white.opacity(0.6))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule().fill(artists ? .white : .clear)
                            )
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { artists = false }
                    } label: {
                        Text("Songs")
                            .font(.system(size: 17, weight: !artists ? .semibold : .regular, design: .rounded))
                            .foregroundStyle(!artists ? Color.appBackground : .white.opacity(0.6))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 9)
                            .background(
                                Capsule().fill(!artists ? .white : .clear)
                            )
                    }
                }
                .frame(alignment: .center)
                .padding(.vertical, 10)
                
                // --- Content ---
                if artists {
                    ArtistsView(selectedTab: $selectedTab)
                } else {
                    SongsView(selectedTab: $selectedTab)
                }
            }
            .frame(maxHeight: .infinity)
            .background(Color.tabBarBackground)
            .navigationDestination(for: ActiveFeed.self) { activeVideo in
                SongsVideosView(activeFeed: activeVideo)
            }
        }
    }
}
