//
//  StageGenerator.swift
//  DungeonGenerator
//
//  Created by mwinkler on 12/30/16.
//  Copyright © 2016 MojoMaze. All rights reserved.
//

import Foundation

class StageBuilder {
    var stage: Stage
    
    init(stage: Stage) throws {
        if (stage.width % 2 == 0 || stage.height % 2 == 0) {
            throw StageError.argumentError(description: "The stage must be odd-sized.")
        }
        self.stage = stage
    }
    
    func fill(tileType: TileType) {
        stage.tiles = Array(repeating: Array(repeating: Tile(type: tileType), count: stage.height), count: stage.width)
    }
    
    func setTile(position: Position, type: TileType) {
        stage.tiles[position.x][position.y].type = type
    }
    
    func getTileType(position: Position) -> TileType? {
        return stage.tiles[position.x][position.y].type
    }
    
}
