//
//  Error.swift
//  StreamPlayer
//
//  Created by Adam Różyński on 17/07/2019.
//

import Foundation

public struct StreamPlayerError {
    
    enum QueueError: Error {
        case noPreviousItem
        case noNextItem
        case invalidIndex(index: Int, message: String)
    }
    
}
