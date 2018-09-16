//
//  Stage.swift
//  DungeonGenerator
//
//  Created by mwinkler on 12/30/16.
//  Copyright © 2016 MojoMaze. All rights reserved.
//

import UIKit

struct Stage {
    
    var tiles = [[Tile]]()
    
    var width: Int {
        return tiles.count
    }
    
    var height: Int {
        guard tiles.count > 0 else {
            return 0
        }
        return tiles[0].count
    }
    
    var bounds: CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    init(width: Int, height: Int) {
        tiles = Array(repeating: Array(repeating: Tile(type: nil), count: height), count: width)
    }
}

struct Tile {
    var type: TileType?
    
    init(type: TileType?) {
        self.type = type
    }
}

enum TileType {
    case wall
    case floor
    case connector
}

enum StageError: Error {
    case argumentError(description: String)
}

struct Room {
    var frame: CGRect
    
    init(frame: CGRect) {
        self.frame = frame
    }
}

struct Position: Hashable {
    var x: Int
    var y: Int
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
