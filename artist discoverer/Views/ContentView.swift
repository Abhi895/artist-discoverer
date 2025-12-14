//
//  ContentView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 28/11/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model = ContentViewModel.shared

    var body: some View {
        ZStack {
            if model.state == .login {
                    LoginView()
            } else if model.state == .discover {
                DiscoverView()
            }
        }
    }
}

#Preview {
    ContentView()
}
