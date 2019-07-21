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
    
    public var remoteCommands = [RemoteCommand]() {
        didSet {
            remoteCommandController.enable(commands: remoteCommands)
        }
    }
    
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

public extension AudioPlayer {
    //MARK: Getters
     var currentTime: TimeInterval {
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
    
    var automaticallyWaitsToMinimizeStalling: Bool {
        get { return avPlayer.automaticallyWaitsToMinimizeStalling }
        set { avPlayer.automaticallyWaitsToMinimizeStalling = newValue }
    }
    
    var volume: Float {
        get { return avPlayer.volume }
        set { avPlayer.volume = newValue }
    }
    
    var isMuted: Bool {
        get { return avPlayer.isMuted }
        set { avPlayer.isMuted = newValue }
    }
    
    var rate: Float {
        get { return avPlayer.rate }
        set { avPlayer.rate = newValue }
    }
    
    var currentItem: AudioItem? {
        return avPlayer.currentItem as? AudioItem
    }
    
    var items: [AudioItem] {
        return avPlayer.items().map { $0 as! AudioItem }
    }
    
}


extension AudioPlayer: AVPlayerObserverDelegate, AVPlayerItemObserverDelegate, AVPlayerItemNotificationObserverDelegate {
    
    //MARK: AVPlayerObserverDelegate
    func player(statusDidChange status: AVPlayer.Status) {
        switch status {
        case .failed:
            event.fail.emit(data: avPlayer.error)
        case .readyToPlay:
            loadNowPlayingMetaValues()
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
            if currentItem == nil {
                state = .idle
            } else {
                state = .paused
            }
        case .playing:
            state = .playing
        case .waitingToPlayAtSpecifiedRate:
            if let _ = avPlayer.currentItem {
                state = .buffering
            } else {
                state = .idle
                event.playbackEnd.emit(data: .playerStopped)
            }
        @unknown default:
            break
        }
        print("⏳ player didChangeTimeControlStatus: \(state.rawValue)")
        event.stateChange.emit(data: state)
    }
    
    //MARK: AVPlayerItemObserverDelegate
    func item(_ item: AVPlayerItem, didUpdateDuration duration: TimeInterval) {
        updateNowPlayingPlaybackValues()
        event.updateDuration.emit(data: duration)
    }
    
    
    //MARK: AVPlayerItemNotificationObserverDelegate
    func itemDidPlayToEndTime(_ item: AVPlayerItem) {
        event.playbackEnd.emit(data: .playedUntilEnd)
        startObservingCurrentItem()
        loadNowPlayingMetaValues()
    }
    
}

extension AudioPlayer: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("playerItem didFinishDownloadingData \(playerItem.debugDescription)")
    }
    
    
}
