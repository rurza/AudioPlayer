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
    }
    
    func player(didChangeTimeControlStatus status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            if currentItem == nil {
                state = .idle
            } else {
                state = .paused
            }
            event.stateChange.emit(data: .paused)
        case .playing:
            state = .playing
            event.stateChange.emit(data: .playing)
        case .waitingToPlayAtSpecifiedRate:
            state = .buffering
            event.stateChange.emit(data: .buffering)
        @unknown default:
            break
        }
    }
    
    //MARK: AudioPlayerItemObserverDelegate
    func item(_ item: AudioPlayerItem, didUpdateDuration duration: Double) {
        
    }
    
    
    //MARK: AVPlayerItemNotificationObserverDelegate
    func itemDidPlayToEndTime() {
        event.playbackEnd.emit(data: .playedUntilEnd)
    }
    
}

extension AudioPlayer: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("playerItem didFinishDownloadingData")
    }

    
}
