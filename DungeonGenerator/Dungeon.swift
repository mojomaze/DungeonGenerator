//
//  Dungeon.swift
//  DungeonGenerator
//
//  Created by mwinkler on 12/30/16.
//  Copyright © 2016 MojoMaze. All rights reserved.
//

import UIKit

class Dungeon: StageBuilder {
    
    let roomTries = 25
    let extraConnectorChance = 10
    let windingChace = 4
    
    var regions = [[Int]]()
    var rooms = [Room]()
    
    private var currentRegion = 0 // zero == no region
    
    private var connectorRegions = [Position: Set<Int>]()
    
    private var stepIncrementor = StepIncrementor()
    
    struct StepIncrementor {
        enum Step: Int {
            case empty = 0, addRooms, addMazes, connectRegions,
                    carveConnectors, removeUnusedConnectors, removeDeadEnds
        }
        
        static let steps = 7
        
        private var lastStep: Step = .empty
        
        mutating func increment(_ i: Int) -> Step? {
            guard let next = Step.init(rawValue: lastStep.rawValue + i) else {
                return nil
            }
            
            lastStep = next
            return next
        }
    }
    
    // MARK:- PUBLIC
    
    override init(stage: Stage) throws {
        do {
            try super.init(stage: stage)
            setup()
        } catch {
            throw error
        }
        
        if (stage.width % 2 == 0 || stage.height % 2 == 0) {
            throw StageError.argumentError(description: "The stage must be odd-sized.")
        }
        self.stage = stage
        
    }
    
    func generate(){
        print("BEGIN generation")
        
        setup()
        
        for _ in 1...StepIncrementor.steps {
            performIncrementedStep(increment: 1)
        }
        
        print("END generation")
        print("generated \(rooms.count) rooms")
        print("generated \(currentRegion + 1) regions")
    }
    
    func nextStep() -> StepIncrementor.Step? {
        return performIncrementedStep(increment: 1)
    }
    
    func clear() {
        setup()
    }
    
    // MARK:- PRIVATE

    
    private func performIncrementedStep(increment: Int) -> StepIncrementor.Step? {
        guard let step = stepIncrementor.increment(increment) else {
            return nil
        }
        switch step {
        case .empty:
            setup()
        case .addRooms:
            addRooms()
        case .addMazes:
            addMazes()
        case .connectRegions:
            connectRegions()
        case .carveConnectors:
            carveConnectors()
        case .removeUnusedConnectors:
            removeUnusedConnectors()
        case .removeDeadEnds:
            removeDeadEnds()
        }
        
        return step
    }
    
    private func setup() {
        currentRegion = 0
        stepIncrementor = StepIncrementor()
        fill(tileType: TileType.wall)
        regions = Array(repeating: Array(repeating: 0, count: stage.height), count: stage.width)
        rooms = [Room]()
        connectorRegions = [Position: Set<Int>]()
    }
    
    private func addRooms() {
        
        print("Adding Rooms:")
        
        let stageWidth = stage.width
        let stageHeight = stage.height
        
        for _ in 0..<roomTries {
            //TODO: move random to utility -> Int to prevent cast
            var size = (arc4random_uniform(4)) * 2 + 1
            size = max(size, 5)
            let rectangularity = arc4random_uniform(1 + size / 2) + 2
            var width = size
            var height = size
            if arc4random_uniform(2) == 0 {
                width += rectangularity
            } else {
                height += rectangularity
            }
            
            //TODO: prevent even size
            if width % 2 == 0 {
                width += 1
            }
            
            if height % 2 == 0 {
                height += 1
            }
            
            let x = Int(arc4random_uniform((UInt32(stageWidth) - width - 1) / 2) * 2 + 1)
            let y = Int(arc4random_uniform((UInt32(stageHeight) - height - 1) / 2) * 2 + 1)
            
            let room = Room(frame: CGRect(x: x, y: y, width: Int(width), height: Int(height)))
            
            var overlaps = false
            
            for other in rooms {
                if room.frame.intersects(other.frame.insetBy(dx: -2, dy: -2)) {
                    overlaps = true
                    break
                }
            }
            
            if overlaps {
                print("Room overlaps -- skipped")
                continue
            }
            
            rooms.append(room)
            
            startRegion()
            
            let xEnd = Int(width) + x
            let yEnd = Int(height) + y
            
            for i in x..<xEnd {
                for j in y..<yEnd {
                    carve(position: Position(x: i, y: j), type: .floor)
                }
            }
        }
    }
    
    private func addMazes() {
        print("Adding Mazes")
        
        for y in 1..<stage.height {
            if y % 2 == 0 { // y += 1 TODO: must be a better way - no c style for loop !!
                continue
            }
            for x in 1..<stage.width {
                if x % 2 == 0 { // every other
                    continue
                }
                let position = Position(x: x, y: y)
                
                if let type = getTileType(position: position), type == .wall {
                    growMaze(start: position)
                }
            }
        }
    }
    
    private func growMaze(start: Position) {
        var cells = [Position]()
        var lastDirection: Direction?
        
        startRegion()
        carve(position: start, type: .floor)
        
        cells.append(start)
        
        while !cells.isEmpty {
            var unmadeCells = [Direction]()
            
            let cell = cells.last!
            
            for direction in Direction.allValues {
                if canCarve(position: cell, direction: direction) {
                    unmadeCells.append(direction)
                }
            }
            
            if !unmadeCells.isEmpty {
                
                var direction: Direction
                
                if let last = lastDirection, unmadeCells.contains(last), arc4random_uniform(UInt32(windingChace)) == 0 {
                    direction = last
                } else {
                    direction = unmadeCells[Int(arc4random_uniform(UInt32(unmadeCells.count)))]
                }
                
                let newCell = Position(x: cell.x + direction.dx * 2, y: cell.y + direction.dy * 2)
                
                carve(position: Position(x: cell.x + direction.dx, y: cell.y + direction.dy) , type: .floor)
                carve(position: newCell , type: .floor)
                
                cells.append(newCell)
                lastDirection = direction
                
            } else {
                cells.removeLast()
                lastDirection = nil
            }
            
        }
    }
    
    private func connectRegions() {
        print("Connecting Regions")
        
        // find all possible connections
        for y in 1..<stage.height - 1 {
            for x in 1..<stage.width - 1 {
                
                let position = Position(x: x, y: y)
                if getTileType(position: position) != .wall {
                    continue
                }
                
                var connectableRegions = Set<Int>()
                for direction in Direction.allValues {
                    let region = regions[position.x + direction.dx][position.y + direction.dy]
                    if region != 0 { // 0 == no region
                        connectableRegions.insert(region)
                    }
                }
                
                if connectableRegions.count > 1 {
                    connectorRegions[position] = connectableRegions
                    //carve(position: position, type: .connector)
                    setTile(position: position, type: .connector)
                }
            }
        }
    }
    
    private func carveConnectors() {
        var connectors = Array(connectorRegions.keys)
        
        // track which regions have been merged
        var merged = [Int: Int]()
        var openRegions = Set<Int>()
        for i in 1...currentRegion {
            merged[i] = i
            openRegions.insert(i)
        }
        
        while openRegions.count > 1 && connectors.count > 0 { // TODO: connectors should not be empty for openRegions
            let connector = connectors.remove(at: Int(arc4random_uniform(UInt32(connectors.count - 1))))
            addJunction(position: connector)
            
            if let regions = connectorRegions[connector] {
                let dest: Set<Int> = [regions.first!]
                let sources = regions.subtracting(dest)
                
                for region in sources {
                    merged[region] = dest.first!
                    openRegions.remove(region)
                }
            }
            
            // remove unneeded connectors
            
            var indexesToRemove = [Int]()
            
            for i in 0..<connectors.count {
                let other = connectors[i]
                
                // don't allow consecutive connectors
                if abs(other.x - connector.x) < 2 {
                    indexesToRemove.append(i)
                    continue
                }
                
                // rmove if regions are already connected
                if let regions = connectorRegions[other] {
                    var unmergedRegions = Set<Int>()
                    for region in regions {
                        if merged[region] == region { // unmerged if it matches itself
                            unmergedRegions.insert(region)
                        }
                    }
                    
                    if unmergedRegions.isEmpty {
                        // not needed but connect randomly for a possible multi region connections
                        
                        if (arc4random_uniform(UInt32(extraConnectorChance))) == 0 {
                            addJunction(position: other)
                        }
                        
                        indexesToRemove.append(i)
                    }
                }
            }
            
            for i in (0..<indexesToRemove.count).reversed() {
                connectors.remove(at: indexesToRemove[i])
            }
        }
        
        print("Open Regions: \(openRegions.count)")
    }
    
    private func removeUnusedConnectors() {
        for y in 1..<stage.height {
            for x in 1..<stage.width {
                let position = Position(x: x, y: y)
                
                if let type = getTileType(position: position), type == .connector {
                    setTile(position: position, type: .wall)
                }
            }
        }

    }
    
    private func removeDeadEnds() {
        var done = false
        
        while (!done) {
            done = true
            
            for y in 1..<stage.height {
                for x in 1..<stage.width {
                    let position = Position(x: x, y: y)
                    
                    if let type = getTileType(position: position), type == .wall {
                        continue
                    }
                    
                    var exits = 0
                    for direction in Direction.allValues {
                        if let type = getTileType(position: Position(x: position.x + direction.dx, y: position.y + direction.dy)), type != .wall {
                            exits += 1
                        }
                    }
                    
                    if exits == 1 {
                        done = false
                        setTile(position: position, type: .wall)
                    }
                }
            }
        }
    }

    
    private func addJunction(position: Position) {
        setTile(position: position, type: TileType.floor)
        print("Juntion added at \(position)")
    }
    
    private func canCarve(position: Position, direction: Direction) -> Bool {
        let boundsCheckPoint = CGPoint(x: position.x + direction.dx * 3, y: position.y + direction.dy * 3)
        if (!stage.bounds.contains(boundsCheckPoint)) {
            return false
        }
        
        guard let type = getTileType(position: Position(x: position.x + direction.dx * 2, y: position.y + direction.dy * 2)) else {
            return false
        }
        
        return type == .wall
    }
    
    private func startRegion() {
        currentRegion += 1
    }
    
    private func carve(position: Position, type: TileType) {
        setTile(position: position, type: type)
        regions[position.x][position.y] = currentRegion
    }
    
}






































