//
//  SongsView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 17/12/2025.
//

import SwiftUI
import AVKit

struct SongsView: View {
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    // Fetch videos from Bundle (Using the same logic as HomeView)
    // In a real app, this would come from VideoManager.shared.likedVideos
    private var videoURLs: [URL] {
        var urls: [URL] = []
        if let videosFromRoot = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            urls.append(contentsOf: videosFromRoot)
        }
        
        print("UUU - \(urls)")
        
        return urls
    }
    
    @State private var tappedIndex: Int = 0
    @State private var videoSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Header Stats
            HStack {
                Text("\(videoURLs.count) Liked Songs")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "line.3.horizontal.decrease.circle") // Sort Icon
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(Array(videoURLs.enumerated()), id: \.offset) { index, url in
                        
                        NavigationLink(value: index) {
                            
                            
                            // Thumbnail Card
                            ZStack(alignment: .bottomLeading) {
                                // 1. The Async Thumbnail
                                VideoThumbnail(videoURL: url)
                                    .aspectRatio(9/16, contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .clipped()
                                
                                // 2. Subtle Gradient Overlay (For depth)
                                LinearGradient(colors: [.clear, .black.opacity(0.4)], startPoint: .center, endPoint: .bottom)
                                
                                // 3. Play Icon Indicator
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .padding(6)
                            }
                            // Force 9:16 Aspect Ratio for the grid cell
                            .aspectRatio(9/16, contentMode: .fit)
                            //                            .onTapGesture {
                            //
                            //                                tappedIndex = index
                            //                                print("TAP TAP - \(tappedIndex)")
                            //                                videoSelected = true
                            //                            }
                        }
                    }
                }
            }
        }
        .background(Color.tabBarBackground)
    }
}

// MARK: - Helper: Async Thumbnail Generator
// Extracts the first frame of a video so you don't need separate image assets
struct VideoThumbnail: View {
    let videoURL: URL
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                // Loading / Placeholder State
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }
    
    
    private func generateThumbnail() {
        // Run on background thread to prevent UI stutter
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            // Capture frame at 0.5 seconds (to avoid black frames at 0.0)
            let time = CMTime(seconds: 0.5, preferredTimescale: 60)
            
            do {
                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                // Update UI on Main Thread
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            } catch {
                print("Failed to generate thumbnail for \(videoURL.lastPathComponent): \(error)")
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SongsView()
    }
}
