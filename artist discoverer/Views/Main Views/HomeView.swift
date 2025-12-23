import SwiftUI
import AVKit

struct HomeView: View {
    @ObservedObject var videoManager = VideoManager.shared
    @State private var currentIndex: Int?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<videoManager.videos.count, id: \.self) { index in
                    VideoCell(index: index, video: videoManager.videos[index])
                    .containerRelativeFrame(.vertical)
                    .id(index)

                }

            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .onChange(of: currentIndex) { _, newIndex in
            if let newIndex {
                videoManager.onScroll(to: newIndex)
            }
        }
        .onAppear {
            videoManager.onScroll(to: 0)
        }
        .ignoresSafeArea(.all)

    }
}
//
//#Preview {
//    HomeView()
//}
//
