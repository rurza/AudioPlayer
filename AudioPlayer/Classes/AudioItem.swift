//
//  AudioItem.swift
//  StreamPlayer
//
//  Created by Adam Różyński on 17/07/2019.
//

public protocol AudioItem {
    func getSourceUrl() -> String
    func getArtist() -> String?
    func getTitle() -> String?
    func getAlbumTitle() -> String?
    func getArtwork(_ handler: @escaping (UIImage?) -> Void)
}
