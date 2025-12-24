//
//  SerachView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        
        VStack {
            HStack(alignment: .top) {
                Text("Search")
                    .font(.system(size: 40, weight: .black, design: .default))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tabBarBackground)
    }
}

//#Preview {
//    SearchView()
//}
