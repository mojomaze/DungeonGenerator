//
//  Direction.swift
//  DungeonGenerator
//
//  Created by mwinkler on 12/30/16.
//  Copyright © 2016 MojoMaze. All rights reserved.
//

import Foundation

// https://developer.apple.com/library/content/samplecode/Pathfinder_GameplayKit/Listings/PathFinder_MazeBuilder_swift.html

/**
 An enum for the cardinal directions. This enables you to randomly
 generate a direction with a random number generator.
 */
enum Direction: Int {
    case left = 0, down, right, up
    
    static let allValues = [left, down, right, up]
    
    /// Generates a random direction.
    static func random() -> Direction {
        /*
         Generate a random number from 0-3, and return a corresponing
         Direction enum.
         */
        // NOTE: modified to use arc4random
        return Direction(rawValue: Int(arc4random_uniform(4)))!
    }
    
    // The offset value for the x-axis associated with a direction.
    // NOTE: return values modified
    var dx: Int {
        switch self {
        case .up, .down: return 0
        case .left:      return -1
        case .right:     return 1
        }
    }
    
    // The offset value for the y-axis associated with a direction.
    var dy: Int {
        switch self {
        case .left, .right: return 0
        case .up:           return -1
        case .down:         return 1
        }
    }
}
