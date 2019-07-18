//
//  AudioPlayer.swift
//  StreamPlayer
//
//  Created by Adam Różyński on 17/07/2019.
//

import AVFoundation

public class AudioPlayer {
    
    public static let shared = AudioPlayer()
    //MARK: - State
    public let nowPlayingInfoController: NowPlayingInfoControllerProtocol
    public let remoteCommandController: RemoteCommandController
    public let event = EventHolder()
    
    public var currentItem: AudioItem? {
        return _currentItem
    }
    fileprivate var _currentItem: CachingPlayerItem?
    
    /**
     Set this to false to disable automatic updating of now playing info for control center and lock screen.
     */
    public var automaticallyUpdateNowPlayingInfo: Bool = true
    
    private(set) public var state: State = .idle
    

    
    //MARK: Private
    private lazy var avPlayer = AVQueuePlayer()
    let playerObserver = AVPlayerObserver()
    var timeEventFrequency: TimeEventFrequency = .everySecond {
        didSet {
            playerTimeObserver.periodicObserverTimeInterval = timeEventFrequency.getTime()
        }
    }
    let playerTimeObserver: AVPlayerTimeObserver
    let playerItemNotificationObserver = AVPlayerItemNotificationObserver()
    let playerItemObserver = AVPlayerItemObserver()
    
    public init(nowPlayingInfoController: NowPlayingInfoControllerProtocol = NowPlayingInfoController(),
                remoteCommandController: RemoteCommandController = RemoteCommandController()) {
        playerTimeObserver = AVPlayerTimeObserver(periodicObserverTimeInterval: timeEventFrequency.getTime())
        self.nowPlayingInfoController = nowPlayingInfoController
        self.remoteCommandController = remoteCommandController
        playerTimeObserver.player = avPlayer
        playerObserver.player = avPlayer
        playerObserver.delegate = self
        playerItemObserver.delegate = self
        playerItemNotificationObserver.delegate = self
        self.remoteCommandController.audioPlayer = self
        playerTimeObserver.registerForPeriodicTimeEvents()
    }
    
    public func play() {
        avPlayer.play()
    }
    
    public func pause() {
        avPlayer.pause()
    }
    
    public func stop() {
        pause()
        avPlayer.removeAllItems()
        event.playbackEnd.emit(data: .playerStopped)
    }
    
    public func togglePlaying() {
        switch avPlayer.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            pause()
        case .paused:
            play()
        @unknown default:
            ()
        }
    }
    
    public func next() {
        avPlayer.advanceToNextItem()
    }
    
    public func previous() {
        
    }
    
    private var seekTime: TimeInterval?
    public func seek(to timeInterval: TimeInterval) {
        avPlayer.seek(to: CMTime(seconds: timeInterval, preferredTimescale: 1000)) { finished in
            self.seekTime = nil
            self.play()
            self.event.seek.emit(data: (seconds: timeInterval, didFinish: finished))
        }
    }
    
}

extension AudioPlayer {
    //MARK: Getters
    public var currentTime: TimeInterval {
        let seconds = avPlayer.currentTime().seconds
        return seconds.isNaN ? 0 : seconds
    }
    
    var duration: TimeInterval {
        if let seconds = _currentItem?.asset.duration.seconds, !seconds.isNaN {
            return seconds
        }
        else if let seconds = _currentItem?.duration.seconds, !seconds.isNaN {
            return seconds
        }
        else if let seconds = _currentItem?.loadedTimeRanges.first?.timeRangeValue.duration.seconds,
            !seconds.isNaN {
            return seconds
        }
        return 0.0
    }
    
    public var automaticallyWaitsToMinimizeStalling: Bool {
        get { return avPlayer.automaticallyWaitsToMinimizeStalling }
        set { avPlayer.automaticallyWaitsToMinimizeStalling = newValue }
    }
    
    public var volume: Float {
        get { return avPlayer.volume }
        set { avPlayer.volume = newValue }
    }
    
    public var isMuted: Bool {
        get { return avPlayer.isMuted }
        set { avPlayer.isMuted = newValue }
    }
    
    public var rate: Float {
        get { return avPlayer.rate }
        set { avPlayer.rate = newValue }
    }
}
