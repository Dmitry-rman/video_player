//
//  VideoPlayerApp.swift
//  VideoPlayer
//
//  Created by Dmitry on 18.03.2023.
//

import SwiftUI

@main
struct VideoPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            let url = Bundle.main.url(forResource: "vid", withExtension: "mp4")!
            VideoPlayerView(url: url)
        }
    }
}
