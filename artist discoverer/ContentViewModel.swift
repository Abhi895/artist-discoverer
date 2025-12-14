//
//  ContentViewModel.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 12/12/2025.
//

import Foundation
internal import Combine

class ContentViewModel: ObservableObject {
//    var objectWillChange: ObservableObjectPublisher
    
    @Published var state : SwiftUIViewCModelState = .discover
    
    static let shared = ContentViewModel()
    
    private init() {}
}

enum SwiftUIViewCModelState {
    case login
    case favourites
    case discover
    case search
    case profile
}
