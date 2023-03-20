//
//  AVPlayerControllerRepresented.swift
//  VideoPlayer
//
//  Created by Dmitry on 20.03.2023.
//
import SwiftUI
import AVKit

struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
