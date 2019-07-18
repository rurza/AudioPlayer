//
//  AudioPlayer+Delegate.swift
//  AudioPlayer
//
//  Created by Adam Różyński on 18/07/2019.
//

import AVFoundation

extension AudioPlayer: AVPlayerObserverDelegate, AudioPlayerItemObserverDelegate, AVPlayerItemNotificationObserverDelegate {
    
    //MARK: AVPlayerObserverDelegate
    func player(statusDidChange status: AVPlayer.Status) {
        switch status {
        case .failed:
            event.fail.emit(data: avPlayer.error)
        case .readyToPlay:
            play()
        case .unknown:
            break
        @unknown default:
            break
        }
//        switch status {
//        case .paused:
//            if currentItem == nil {
//                state = .idle
//            }
//            else {
//                self._state = .paused
//            }
//        case .waitingToPlayAtSpecifiedRate:
//            self._state = .buffering
//        case .playing:
//            self._state = .playing
//        @unknown default:
//            break
//        }
    }
    
    func player(didChangeTimeControlStatus status: AVPlayer.TimeControlStatus) {
        
    }
    
    //MARK: AudioPlayerItemObserverDelegate
    func item(_ item: AudioPlayerItem, didUpdateDuration duration: Double) {
        
    }
    
    
    //MARK: AVPlayerItemNotificationObserverDelegate
    func itemDidPlayToEndTime() {
        
    }
    
}

extension AudioPlayer: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("playerItem didFinishDownloadingData")
    }

    
}
