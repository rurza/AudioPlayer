//
//  AudioPlayer+NowPlaying.swift
//  AudioPlayer
//
//  Created by Adam Różyński on 18/07/2019.
//

import MediaPlayer

extension AudioPlayer {
    // MARK: - NowPlayingInfo
    
    /**
     Loads NowPlayingInfo-meta values with the values found in the current `AudioItem`. Use this if a change to the `AudioItem` is made and you want to update the `NowPlayingInfoController`s values.
     
     Reloads:
     - Artist
     - Title
     - Album title
     - Album artwork
     */
    public func loadNowPlayingMetaValues() {
        guard let item = currentItem else { return }
        
        nowPlayingInfoController.set(keyValues: [
            MediaItemProperty.artist(item.getArtist()),
            MediaItemProperty.title(item.getTitle()),
            MediaItemProperty.albumTitle(item.getAlbumTitle()),
            ])
        
        loadArtwork(forItem: item)
    }
    
    /**
     Resyncs the playbackvalues of the currently playing `AudioItem`.
     
     Will resync:
     - Current time
     - Duration
     - Playback rate
     */
    public func updateNowPlayingPlaybackValues() {
        updateNowPlayingDuration(duration)
        updateNowPlayingCurrentTime(currentTime)
        updateNowPlayingRate(rate)
    }
    
    private func updateNowPlayingDuration(_ duration: Double) {
        nowPlayingInfoController.set(keyValue: MediaItemProperty.duration(duration))
    }
    
    private func updateNowPlayingRate(_ rate: Float) {
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.playbackRate(Double(rate)))
    }
    
    private func updateNowPlayingCurrentTime(_ currentTime: Double) {
        nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.elapsedPlaybackTime(currentTime))
    }
    
    private func loadArtwork(forItem item: AudioItem) {
        item.getArtwork { (image) in
            if let image = image {
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                    return image
                })
                self.nowPlayingInfoController.set(keyValue: MediaItemProperty.artwork(artwork))
            }
        }
    }
}

