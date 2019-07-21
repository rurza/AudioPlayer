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
    
    /**
     Set this to false to disable automatic updating of now playing info for control center and lock screen.
     */
    public var automaticallyUpdateNowPlayingInfo = true
    public var playAutomatically = false
    
    fileprivate(set) public var state: State = .idle
    
    //MARK: Private
    fileprivate lazy var avPlayer = AVQueuePlayer()
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
        
        playerObserver.player = avPlayer
        playerObserver.delegate = self
        playerObserver.startObserving()
        
        playerItemObserver.delegate = self
        playerItemNotificationObserver.delegate = self
        
        self.remoteCommandController.audioPlayer = self
        
        playerTimeObserver.player = avPlayer
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
        startObservingCurrentItem()
        loadNowPlayingMetaValues()
        event.playbackEnd.emit(data: .skippedToNext)
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
    
    public func addItems(items: [AudioItem]) {
        let audioItems = items.map { AudioPlayerItem(audioItem: $0) }
        for item in audioItems {
            if avPlayer.canInsert(item, after: nil) {
                avPlayer.insert(item, after: nil)
                item.delegate = self
            }
        }
        if playAutomatically {
            play()
        }
    }
    
    fileprivate func startObservingCurrentItem() {
        if let currentItem = avPlayer.currentItem {
            playerItemNotificationObserver.startObserving(item: currentItem)
            playerItemObserver.startObserving(item: currentItem)
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
        if let seconds = avPlayer.currentItem?.asset.duration.seconds, !seconds.isNaN {
            return seconds
        }
        else if let seconds = avPlayer.currentItem?.duration.seconds, !seconds.isNaN {
            return seconds
        }
        else if let seconds = avPlayer.currentItem?.loadedTimeRanges.first?.timeRangeValue.duration.seconds,
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
    
    var currentItem: AudioItem? {
        return avPlayer.currentItem as? AudioItem
    }
    
}


extension AudioPlayer: AVPlayerObserverDelegate, AVPlayerItemObserverDelegate, AVPlayerItemNotificationObserverDelegate {
    
    //MARK: AVPlayerObserverDelegate
    func player(statusDidChange status: AVPlayer.Status) {
        switch status {
        case .failed:
            print("⏯ player statusDidChange failed")
            event.fail.emit(data: avPlayer.error)
        case .readyToPlay:
            print("⏯ player statusDidChange readyToPlay")
            loadNowPlayingMetaValues()
            remoteCommandController.enable(commands: [.changePlaybackPosition, .togglePlayPause, .next])
            
            if playAutomatically {
                play()
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    func player(didChangeTimeControlStatus status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            print("⏳ player didChangeTimeControlStatus: paused")
            if currentItem == nil {
                state = .idle
            } else {
                state = .paused
            }
            event.stateChange.emit(data: .paused)
        case .playing:
            print("⏳ player didChangeTimeControlStatus: playing")
            state = .playing
            event.stateChange.emit(data: .playing)
        case .waitingToPlayAtSpecifiedRate:
            if let _ = avPlayer.currentItem {
                print("⏳ player didChangeTimeControlStatus: buffering")
                state = .buffering
                event.stateChange.emit(data: .buffering)
            } else {
                print("⏳ player didChangeTimeControlStatus: idle")
                state = .idle
                event.stateChange.emit(data: .idle)
                event.playbackEnd.emit(data: .playerStopped)
                
            }
        @unknown default:
            break
        }
    }
    
    //MARK: AVPlayerItemObserverDelegate
    func item(_ item: AVPlayerItem, didUpdateDuration duration: TimeInterval) {
        print("Item \(item) didUpdateDuration: \(duration)")
        updateNowPlayingPlaybackValues()
        event.updateDuration.emit(data: duration)
    }
    
    
    //MARK: AVPlayerItemNotificationObserverDelegate
    func itemDidPlayToEndTime(_ item: AVPlayerItem) {
        print("itemDidPlayToEndTime \(item)")
        event.playbackEnd.emit(data: .playedUntilEnd)
        startObservingCurrentItem()
        loadNowPlayingMetaValues()
    }
    
}

extension AudioPlayer: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("playerItem didFinishDownloadingData \(playerItem)")
    }
    
    
}
