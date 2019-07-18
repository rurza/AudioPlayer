//
//  AudioPlayer+Delegate.swift
//  AudioPlayer
//
//  Created by Adam Różyński on 18/07/2019.
//

import AVFoundation

extension AudioPlayer: AVPlayerObserverDelegate, AVPlayerItemObserverDelegate, AVPlayerItemNotificationObserverDelegate {
    
    //MARK: AVPlayerObserverDelegate
    func player(statusDidChange status: AVPlayer.Status) {
        
    }
    
    func player(didChangeTimeControlStatus status: AVPlayer.TimeControlStatus) {
        
    }
    
    //MARK: AVPlayerItemObserverDelegate
    func item(didUpdateDuration duration: Double) {
        
    }
    
    //MARK: AVPlayerItemNotificationObserverDelegate
    func itemDidPlayToEndTime() {
        
    }
    
}
