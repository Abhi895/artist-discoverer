//
//  VideoModel.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 23/12/2025.
//

import SwiftUI

struct Video {
    var id: Int = 0
    var url: URL?
    let artistName: String
    let songDesc: String
    let hashtags: [String]
    let songName: String
    var liked: Bool = false
    var saved: Bool = false
    

}
