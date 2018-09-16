//
//  DungeonView.swift
//  DungeonGenerator
//
//  Created by mwinkler on 1/1/17.
//  Copyright © 2017 MojoMaze. All rights reserved.
//

import UIKit

class DungeonView: UIView {

    var stage: Stage? {
        didSet {
            setNeedsDisplay()
        }
    }
    var tileSize: CGFloat = 0.0
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.black
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        if let stage = self.stage  {
            tileSize = rect.width / CGFloat(stage.width)
            
            for y in 0..<stage.height {
                for x in 0..<stage.width {
                    if let tileType = stage.tiles[x][y].type {
                        switch tileType {
                        case .floor:
                            let path = UIBezierPath()
                            let start = CGPoint(x: CGFloat(x) * tileSize, y: CGFloat(y) * tileSize)
                            path.move(to: start)
                            path.addLine(to: CGPoint(x: start.x + tileSize, y: start.y))
                            path.addLine(to: CGPoint(x: start.x + tileSize, y: start.y + tileSize))
                            path.addLine(to: CGPoint(x: start.x, y: start.y + tileSize))
                            path.close()
                            
                            context?.setFillColor(UIColor.lightGray.cgColor)
                            context?.setStrokeColor(UIColor.black.cgColor)
                            path.fill()
                            path.stroke()
                        
                        case .connector:
                            let path = UIBezierPath()
                            let start = CGPoint(x: CGFloat(x) * tileSize, y: CGFloat(y) * tileSize)
                            path.move(to: start)
                            path.addLine(to: CGPoint(x: start.x + tileSize, y: start.y))
                            path.addLine(to: CGPoint(x: start.x + tileSize, y: start.y + tileSize))
                            path.addLine(to: CGPoint(x: start.x, y: start.y + tileSize))
                            path.close()
                            
                            context?.setFillColor(UIColor.brown.cgColor)
                            context?.setStrokeColor(UIColor.black.cgColor)
                            path.fill()
                            path.stroke()
                        default:
                            break
                        }
                    }
                }
            }
        }
    }

}
