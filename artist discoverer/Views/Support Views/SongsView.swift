////
////  SongsView.swift
////  artist discoverer
////
////  Grid view of liked/saved songs
////
//
//import SwiftUI
//import AVKit
//
//struct SongsView: View {
//    let columns = [
//        GridItem(.flexible(), spacing: 1),
//        GridItem(.flexible(), spacing: 1),
//        GridItem(.flexible(), spacing: 1)
//    ]
//    
//    @ObservedObject private var videoManager = VideoManager.shared
//    
//    private var videoURLs: [URL] {
//        return videoManager.likedVideoURLs
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            
//            // Header Stats
//            HStack {
//                Text("\(videoURLs.count) Liked Songs")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                Spacer()
//                Image(systemName: "line.3.horizontal.decrease.circle")
//                    .foregroundColor(.white)
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 10)
//            
//            ScrollView(showsIndicators: false) {
//                LazyVGrid(columns: columns, spacing: 1) {
//                    ForEach(Array(videoURLs.enumerated()), id: \.offset) { index, url in
//                        
//                        NavigationLink(value: index) {
//                            // Thumbnail Card
//                            ZStack(alignment: .bottomLeading) {
//                                VideoThumbnail(videoURL: url)
//                                    .aspectRatio(9/16, contentMode: .fill)
//                                    .frame(minWidth: 0, maxWidth: .infinity)
//                                    .clipped()
//                                
//                                LinearGradient(
//                                    colors: [.clear, .black.opacity(0.4)],
//                                    startPoint: .center,
//                                    endPoint: .bottom
//                                )
//                                
//                                Image(systemName: "play.fill")
//                                    .font(.system(size: 10))
//                                    .foregroundColor(.white)
//                                    .padding(6)
//                            }
//                            .aspectRatio(9/16, contentMode: .fit)
//                        }
//                    }
//                }
//            }
//        }
//        .background(Color.tabBarBackground)
//    }
//}
//
//// MARK: - Async Thumbnail Generator
//
//struct VideoThumbnail: View {
//    let videoURL: URL
//    @State private var image: UIImage? = nil
//    
//    var body: some View {
//        Group {
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
//            } else {
//                ZStack {
//                    Color.gray.opacity(0.2)
//                    ProgressView()
//                        .scaleEffect(0.5)
//                }
//            }
//        }
//        .onAppear {
//            generateThumbnail()
//        }
//    }
//    
//    private func generateThumbnail() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let asset = AVURLAsset(url: videoURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
//            
//            let time = CMTime(seconds: 0.5, preferredTimescale: 60)
//            
//            do {
//                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
//                let uiImage = UIImage(cgImage: cgImage)
//                
//                DispatchQueue.main.async {
//                    self.image = uiImage
//                }
//            } catch {
//                print("Failed to generate thumbnail: \(error)")
//            }
//        }
//    }
//}
