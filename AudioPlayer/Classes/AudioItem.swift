//
//  AudioItem.swift
//  StreamPlayer
//
//  Created by Adam Różyński on 17/07/2019.
//

public protocol AudioItem {
    func getSourceUrl() -> URL
    func getArtist() -> String?
    func getTitle() -> String?
    func getAlbumTitle() -> String?
    func getArtwork(_ handler: @escaping (UIImage?) -> Void)
}

extension AudioItem {
    public func isTheSameTrackAs(_ another: AudioItem?) -> Bool {
        return getTitle() == another?.getTitle() && getArtist() == another?.getArtist()
    }
}
