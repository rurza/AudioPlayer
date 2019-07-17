//
//  StreamPlayer.swift
//  StreamPlayer
//
//  Created by Adam Różyński on 17/07/2019.
//

import AVFoundation

public class StreamPlayer {
    
    public static let shared = StreamPlayer()
    
    private lazy var avPlayer = AVQueuePlayer()
    
    private(set) public var state: StreamPlayerState = .idle
    
    public func play() {
        
    }
    
    public func pause() {
        
    }
    
    public func stop() {
        
    }
    
    public func togglePlaying() {
        
    }
    
    public func next() {
        
    }
    
    public func previous() {
        
    }
    
    public func seek(to timeInterval: TimeInterval) {
        
    }
    
    var currentTime: TimeInterval = 0
    
    
}
