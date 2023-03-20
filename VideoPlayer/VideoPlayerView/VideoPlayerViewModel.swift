//
//  PlayerViewModel.swift
//  VideoPlayer
//
//  Created by Dmitry on 19.03.2023.
//

import Foundation
import Combine
import AVKit

class VideoPlayerViewModel: ObservableObject{
    
    @Published var player: AVPlayer
    @Published var currentTime: Int = 0
    @Published var isPlayerReady: Bool = false
    @Published var isPlaying: Bool = false
    @Published var progressTime: Double = 0
    
    var timeString: String {
        let seconds = currentTime
        return String(format: "%02d:%02d", seconds/60, seconds%60) as String
    }
    
    private var isSeekInProgress = false
    private var chaseTime = CMTime.zero
    private var observer: NSKeyValueObservation?
    
    let timeScale: Double = 100.0
    
    var duration: TimeInterval{
        return  (player.currentItem?.duration.seconds ?? 0 ) * timeScale
    }
    
    init(url: URL){
        
        let item = AVPlayerItem(url: url)
        item.seekingWaitsForVideoCompositionRendering = false
        player = AVPlayer(playerItem: item)
        player.rate = 0
        
        // Register as an observer of the player item's status property
         self.observer = item.observe(\.status, options:  [.new, .old],
                                             changeHandler: { [weak self] (playerItem, change) in
             guard let self = self else {return}
             if playerItem.status == .readyToPlay {
                 self.isPlayerReady = true
             }
         })
        
       player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                                  queue: DispatchQueue.main,
                                                  using: {[weak self] (time) in
           
            guard let self = self else {return}
            
           if self.player.currentItem?.status == .readyToPlay {
               self.currentTime = Int(self.player.currentTime().seconds)
                if self.isPlaying {
                    self.progressTime = Double(self.currentTime) * self.timeScale
                }
            }
        }
        )
        seek(to: 0)
    }
    
    func play(){
        player.play()
    }
    
    func pause(){
        player.pause()
    }
    
    func seek(to value: TimeInterval) {
        
        if self.isPlaying == true {
            return
        }
        
        let time: CMTime = CMTimeMake(value: Int64(value * timeScale),
                                      timescale: Int32(100 * timeScale))

        seekSmoothlyToTime(newChaseTime: time)
    }
    
    func seek(by value: Int){
        
        player.currentItem?.step(byCount: value)
    }
    
    private func seekSmoothlyToTime(newChaseTime: CMTime) {
        
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime
            
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    private func trySeekToChaseTime() {
        
        guard player.status == .readyToPlay else {
            return
        }
        actuallySeekToTime()
    }
    
    private func actuallySeekToTime() {
        
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        
        player.seek(to: seekTimeInProgress,
                    toleranceBefore: .zero,
                    toleranceAfter: .zero) { [weak self] _ in
            guard let self = self else { return }
            
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime()
            }
        }
    }
    
    deinit{
        observer?.invalidate()
        observer = nil
        player.removeTimeObserver(self)
    }
    
}
