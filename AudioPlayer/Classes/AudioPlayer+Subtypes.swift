//
//  StreamPlayerState.swift
//  StreamPlayer
//
//  Created by Jørgen Henrichsen on 10/03/2018.
//  Modified by Adam Różyński on 17/07/2019
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import AVFoundation

public extension AudioPlayer {
    
    /**
     The current state of the AudioPlayer.
     */
    enum State: String {
        
        /// An asset is being loaded for playback.
        case loading
        
        /// The current item is loaded, and the player is ready to start playing.
        case ready
        
        /// The current item is playing, but are currently buffering.
        case buffering
        
        /// The player is paused.
        case paused
        
        /// The player is playing.
        case playing
        
        /// No item loaded, the player is stopped.
        case idle
        
    }
    
    enum PlaybackEndedReason: String {
        case playedUntilEnd
        case playerStopped
        case skippedToNext
        case skippedToPrevious
        case jumpedToIndex
    }
    
    enum TimeEventFrequency {
        case everySecond
        case everyHalfSecond
        case everyQuarterSecond
        case custom(time: CMTime)
        
        func getTime() -> CMTime {
            switch self {
            case .everySecond: return CMTime(value: 1, timescale: 1)
            case .everyHalfSecond: return CMTime(value: 1, timescale: 2)
            case .everyQuarterSecond: return CMTime(value: 1, timescale: 4)
            case .custom(let time): return time
            }
        }
    }

}

