//
//  ViewController.swift
//  DungeonGenerator
//
//  Created by mwinkler on 12/30/16.
//  Copyright © 2016 MojoMaze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var dungeonView: DungeonView!
    
    
    var dungeon: Dungeon?

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try dungeon = Dungeon(stage: Stage(width: 51, height: 51))
            if let dungeon = self.dungeon {
                dungeonView.stage = dungeon.stage
            }
            
        } catch StageError.argumentError(let description) {
            print(description)
        } catch {
            print("Dungeon generate error: \(error)")
        }
        
        dungeon?.generate()
        dungeonView.stage = dungeon?.stage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func generate() {
        if let dungeon = self.dungeon {
            dungeon.generate()
            dungeonView.stage = dungeon.stage
        }
    }
    
    @IBAction func next() {
        if let dungeon = self.dungeon {
            guard let _ = dungeon.nextStep() else {
                dungeon.clear()
                dungeonView.stage = dungeon.stage
                next()
                return
            }
            dungeonView.stage = dungeon.stage
        }
    }
    
    @IBAction func clear() {
        if let dungeon = self.dungeon {
            dungeon.clear()
            dungeonView.stage = dungeon.stage
        }

    }

}

