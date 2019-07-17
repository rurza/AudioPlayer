//
//  StreamPlayerState.swift
//  StreamPlayer
//
//  Created by Jørgen Henrichsen on 10/03/2018.
//  Modified by Adam Różyński on 17/07/2019
//  Copyright © 2018 Jørgen Henrichsen. All rights reserved.
//

import Foundation


/**
 The current state of the StreamPlayer.
 */
public enum StreamPlayerState: String {
    
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

public enum PlaybackEndedReason: String {
    case playedUntilEnd
    case playerStopped
    case skippedToNext
    case skippedToPrevious
    case jumpedToIndex
}
