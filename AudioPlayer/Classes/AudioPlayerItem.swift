//
//  AudioPlayerItem.swift
//  AudioPlayer
//
//  Created by Adam Różyński on 18/07/2019.
//

import UIKit

open class AudioPlayerItem: CachingPlayerItem {
    
    internal let audioItem: AudioItem
    
    init(audioItem: AudioItem) {
        self.audioItem = audioItem
        let url = audioItem.getSourceUrl()
        super.init(url: url, customFileExtension: nil)
    }
    
    init(data: Data,
         mimeType: String,
         fileExtension: String,
         audioItem: AudioItem) {
        self.audioItem = audioItem
        super.init(data: data, mimeType: mimeType, fileExtension: fileExtension)
    }
    
    override open var debugDescription: String {
         return "\(String(describing: audioItem.getArtist())) - \(String(describing: audioItem.getTitle()))"
    }
}

extension AudioPlayerItem: AudioItem {
    
    public func getSourceUrl() -> URL {
        return audioItem.getSourceUrl()
    }
    
    public func getArtist() -> String? {
        return audioItem.getArtist()
    }
    
    public func getTitle() -> String? {
        return audioItem.getTitle()
    }
    
    public func getAlbumTitle() -> String? {
        return audioItem.getAlbumTitle()
    }
    
    public func getArtwork(_ handler: @escaping (UIImage?) -> Void) {
        audioItem.getArtwork(handler)
    }
}
