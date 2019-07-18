//
//  AudioPlayerItemObserver.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 28/07/2018.
//

import Foundation
import AVFoundation

protocol AudioPlayerItemObserverDelegate: class {
    
    /**
     Called when the observed item updates the duration.
     */
    func item(_ item: AudioPlayerItem, didUpdateDuration duration: Double)
    
}

/**
 Observing an AVPlayers status changes.
 */
class AudioPlayerItemObserver: NSObject {
    
    private static var context = 0
    private let main: DispatchQueue = .main
    
    private struct AVPlayerItemKeyPath {
        static let duration = #keyPath(AVPlayerItem.duration)
        static let loadedTimeRanges = #keyPath(AVPlayerItem.loadedTimeRanges)
    }
    
    private(set) var isObserving: Bool = false
    
    private(set) weak var observingItem: AudioPlayerItem?
    weak var delegate: AudioPlayerItemObserverDelegate?
    
    deinit {
        stopObservingCurrentItem()
    }
    
    /**
     Start observing an item. Will remove self as observer from old item, if any.
     
     - parameter item: The player item to observe.
     */
    func startObserving(item: AudioPlayerItem) {
        self.stopObservingCurrentItem()
        self.isObserving = true
        self.observingItem = item
        item.addObserver(self, forKeyPath: AVPlayerItemKeyPath.duration, options: [.new], context: &AudioPlayerItemObserver.context)
        item.addObserver(self, forKeyPath: AVPlayerItemKeyPath.loadedTimeRanges, options: [.new], context: &AudioPlayerItemObserver.context)
    }
    
    func stopObservingCurrentItem() {
        guard let observingItem = observingItem, isObserving else {
            return
        }
        observingItem.removeObserver(self, forKeyPath: AVPlayerItemKeyPath.duration, context: &AudioPlayerItemObserver.context)
        observingItem.removeObserver(self, forKeyPath: AVPlayerItemKeyPath.loadedTimeRanges, context: &AudioPlayerItemObserver.context)
        self.isObserving = false
        self.observingItem = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &AudioPlayerItemObserver.context, let observedKeyPath = keyPath else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch observedKeyPath {
        case AVPlayerItemKeyPath.duration:
            if let duration = change?[.newKey] as? CMTime,
                let item = observingItem {
                self.delegate?.item(item, didUpdateDuration: duration.seconds)
            }
        
        case AVPlayerItemKeyPath.loadedTimeRanges:
            if let ranges = change?[.newKey] as? [NSValue],
                let duration = ranges.first?.timeRangeValue.duration,
                let item = observingItem {
                self.delegate?.item(item, didUpdateDuration: duration.seconds)
            }
        default: break
            
        }
    }
    
}