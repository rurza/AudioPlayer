//
//  File.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 20/03/2018.
//  Changes by Adam Różyński on 17/07/2019.
//

import Foundation
import MediaPlayer

public protocol RemoteCommandable {
    func getCommands() ->  [RemoteCommand]
}

public class RemoteCommandController {
    
    private let center: MPRemoteCommandCenter
    
    weak var audioPlayer: AudioPlayer?
    
    var commandTargetPointers: [String: Any] = [:]
    
    /**
     Create a new RemoteCommandController.
     
     - parameter remoteCommandCenter: The MPRemoteCommandCenter used. Default is `MPRemoteCommandCenter.shared()`
     */
    public init(remoteCommandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()) {
        center = remoteCommandCenter
    }
    
    internal func enable(commands: [RemoteCommand]) {
        disable(commands: RemoteCommand.all())
        commands.forEach { (command) in
            enable(command: command)
        }
    }
    
    internal func disable(commands: [RemoteCommand]) {
        commands.forEach { (command) in
            disable(command: command)
        }
    }
    
    private func enableCommand<Command: RemoteCommandProtocol>(_ command: Command) {
        center[keyPath: command.commandKeyPath].isEnabled = true
        commandTargetPointers[command.id] = center[keyPath: command.commandKeyPath].addTarget(handler: self[keyPath: command.handlerKeyPath])
    }
    
    private func disableCommand<Command: RemoteCommandProtocol>(_ command: Command) {
        center[keyPath: command.commandKeyPath].isEnabled = false
        center[keyPath: command.commandKeyPath].removeTarget(commandTargetPointers[command.id])
        commandTargetPointers.removeValue(forKey: command.id)
    }
    
    private func enable(command: RemoteCommand) {
        switch command {
        case .play: enableCommand(PlayBackCommand.play)
        case .pause: enableCommand(PlayBackCommand.pause)
        case .stop: enableCommand(PlayBackCommand.stop)
        case .togglePlayPause: enableCommand(PlayBackCommand.togglePlayPause)
        case .next: enableCommand(PlayBackCommand.nextTrack)
        case .previous: enableCommand(PlayBackCommand.previousTrack)
        case .changePlaybackPosition: enableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
        case .skipForward(let preferredIntervals): enableCommand(SkipIntervalCommand.skipForward.set(preferredIntervals: preferredIntervals))
        case .skipBackward(let preferredIntervals): enableCommand(SkipIntervalCommand.skipBackward.set(preferredIntervals: preferredIntervals))
        case .like(let isActive, let localizedTitle, let localizedShortTitle):
            enableCommand(FeedbackCommand.like.set(isActive: isActive, localizedTitle: localizedTitle, localizedShortTitle: localizedShortTitle))
        case .dislike(let isActive, let localizedTitle, let localizedShortTitle):
            enableCommand(FeedbackCommand.dislike.set(isActive: isActive, localizedTitle: localizedTitle, localizedShortTitle: localizedShortTitle))
        case .bookmark(let isActive, let localizedTitle, let localizedShortTitle):
            enableCommand(FeedbackCommand.bookmark.set(isActive: isActive, localizedTitle: localizedTitle, localizedShortTitle: localizedShortTitle))
        }
    }
    
    private func disable(command: RemoteCommand) {
        switch command {
        case .play: disableCommand(PlayBackCommand.play)
        case .pause: disableCommand(PlayBackCommand.pause)
        case .stop: disableCommand(PlayBackCommand.stop)
        case .togglePlayPause: disableCommand(PlayBackCommand.togglePlayPause)
        case .next: disableCommand(PlayBackCommand.nextTrack)
        case .previous: disableCommand(PlayBackCommand.previousTrack)
        case .changePlaybackPosition: disableCommand(ChangePlaybackPositionCommand.changePlaybackPosition)
        case .skipForward(_): disableCommand(SkipIntervalCommand.skipForward)
        case .skipBackward(_): disableCommand(SkipIntervalCommand.skipBackward)
        case .like(_, _, _): disableCommand(FeedbackCommand.like)
        case .dislike(_, _, _): disableCommand(FeedbackCommand.dislike)
        case .bookmark(_, _, _): disableCommand(FeedbackCommand.bookmark)
        }
    }
    
    // MARK: - Handlers
    
    public lazy var handlePlayCommand: RemoteCommandHandler = handlePlayCommandDefault
    public lazy var handlePauseCommand: RemoteCommandHandler = handlePauseCommandDefault
    public lazy var handleStopCommand: RemoteCommandHandler = handleStopCommandDefault
    public lazy var handleTogglePlayPauseCommand: RemoteCommandHandler = handleTogglePlayPauseCommandDefault
    public lazy var handleSkipForwardCommand: RemoteCommandHandler  = handleSkipForwardCommandDefault
    public lazy var handleSkipBackwardCommand: RemoteCommandHandler = handleSkipBackwardDefault
    public lazy var handleChangePlaybackPositionCommand: RemoteCommandHandler  = handleChangePlaybackPositionCommandDefault
    public lazy var handleNextTrackCommand: RemoteCommandHandler = handleNextTrackCommandDefault
    public lazy var handlePreviousTrackCommand: RemoteCommandHandler = handlePreviousTrackCommandDefault
    public lazy var handleLikeCommand: RemoteCommandHandler = handleLikeCommandDefault
    public lazy var handleDislikeCommand: RemoteCommandHandler = handleDislikeCommandDefault
    public lazy var handleBookmarkCommand: RemoteCommandHandler = handleBookmarkCommandDefault
    
    private func handlePlayCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handlePauseCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleStopCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            return .success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleTogglePlayPauseCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let audioPlayer = audioPlayer {
            audioPlayer.togglePlaying()
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleSkipForwardCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = audioPlayer {
            audioPlayer.seek(to: audioPlayer.currentTime + Double(truncating: interval))
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleSkipBackwardDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let command = event.command as? MPSkipIntervalCommand,
            let interval = command.preferredIntervals.first,
            let audioPlayer = audioPlayer {
            audioPlayer.seek(to: audioPlayer.currentTime - Double(truncating: interval))
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleChangePlaybackPositionCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let event = event as? MPChangePlaybackPositionCommandEvent,
            let audioPlayer = audioPlayer {
            audioPlayer.seek(to: event.positionTime)
            return MPRemoteCommandHandlerStatus.success
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleNextTrackCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let player = audioPlayer {
            do {
                try player.next()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handlePreviousTrackCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let player = audioPlayer {
            do {
                try player.previous()
                return MPRemoteCommandHandlerStatus.success
            }
            catch let error {
                return getRemoteCommandHandlerStatus(forError: error)
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
    private func handleLikeCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        return MPRemoteCommandHandlerStatus.success
    }
    
    private func handleDislikeCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        return MPRemoteCommandHandlerStatus.success
    }
    
    private func handleBookmarkCommandDefault(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        return MPRemoteCommandHandlerStatus.success
    }
    
    private func getRemoteCommandHandlerStatus(forError error: Error) -> MPRemoteCommandHandlerStatus {
        if let error = error as? StreamPlayerError.QueueError {
            switch error {
            case .noNextItem, .noPreviousItem, .invalidIndex(_, _):
                return MPRemoteCommandHandlerStatus.noSuchContent
            }
        }
        return MPRemoteCommandHandlerStatus.commandFailed
    }
    
}
