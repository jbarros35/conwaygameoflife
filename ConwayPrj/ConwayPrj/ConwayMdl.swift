//
//  ConwayMdl.swift
//  ConwayPrj
//
//  Created by Jose on 21/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

class ConwayMdl {
    
    public var world: [[Int]] = []
    public var worldSize: Int = 10
    public var generations: Int = 1
    
    var markToDeath: [(Int,Int)] = []
    var markToBorn: [(Int,Int)] = []
    
    // Init world
    func initWorld() {
        for _ in 0..<worldSize {
            var line: [Int] = []
            for _ in 0..<worldSize {
                line.append(0)
            }
            world.append(line)
        }
    }
    
    public func seedWorld() {
        // toad
        world[1][1]=1
        world[1][2]=1
        world[1][3]=1
        world[2][2]=1
        world[2][3]=1
        world[2][4]=1
        // block
        world[6][1]=1
        world[6][2]=1
        world[7][1]=1
        world[7][2]=1
        // Beehive
        world[8][1]=1
        world[8][2]=1
    }
    
    func printWorld() {
        for line in world {
            print(line)
        }
    }
    
    func runGenerations() {
        for gen in 0..<generations {
            
            // erase born and life arrays
            markToDeath = []
            markToBorn = []
            
            print("running generation #\(gen)")
            printWorld()
            for (line, element) in world.enumerated() {
                for (col, _) in element.enumerated() {
                    // print("El: \(col, line): \(cell)")
                    validateLife(x:col, y:line)
                }
            }
            // kill creatures
            for cell in markToDeath {
                // print(cell)
                world[cell.0][cell.1] = 0
            }
            // born new creatures
            for cell in markToBorn {
                world[cell.0][cell.1] = 1
            }
        }
    }
    
    // check who is alive
    func validateLife(x:Int,y:Int) {
        // 1. less than 2 neighbours alive dies
        // 2. two or more alive neighbours alive lives for the next generation
        // 3. more than 3 neighbours dies
        // 4. if exactly 3 alive and its empty turns alive.
        var alive: Bool = world[x][y] != 0
        let neighboursAlive: Int = getNeighbours(x:x, y:y)
        if alive {
            if neighboursAlive < 2 {
                //print("Dead: \(x,y) rule 1 neighbourscount: \(neighboursAlive)")
                markToDeath.append((x, y))
            } else if neighboursAlive >= 2 && neighboursAlive <= 3 {
                //print("Alive: \(x,y) rule 2 neighbourscount: \(neighboursAlive)")
            } else if neighboursAlive > 3 {
                //print("Dead: \(x,y) rule 3 neighbourscount: \(neighboursAlive)")
                markToDeath.append((x, y))
            }
        } else {
            if neighboursAlive == 3 {
                //print("Alive: \(x,y) rule 4 neighbourscount: \(neighboursAlive)")
                markToBorn.append((x, y))
            }
        }
    }
    
    // return all neighbours indices for desired x,y indices in the world
    func getNeighbours(x:Int, y:Int) -> Int {
        let arr = [
            [(x-1, y-1),(x, y-1),(x+1, y-1)],
            [(x-1, y),           (x+1, y)  ],
            [(x-1, y+1),(x, y+1),(x+1, y+1)]
        ]
        //print("\(x,y)->")
        //var neighbours: [Int] = []
        var sum: Int = 0
        for ln in arr {
            for cell in ln {
                if (cell.0 >= 0 && cell.1 >= 0)
                    && (cell.0 < world.endIndex && cell.1 < world.endIndex) {
                    sum = sum + world[cell.0][cell.1]
                }
            }
        }
        return sum
    }
}
