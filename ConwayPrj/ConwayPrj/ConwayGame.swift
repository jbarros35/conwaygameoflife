//
//  ConwayGame.swift
//  ConwayPrj
//
//  Created by Jose on 22/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

class ConwayGame {
    
    public var world: [[SquareButton]] = []
    public var worldSize: Int = 10
    public var generations: Int = 10
    
    public var gameStatus:GameStatus?
    
    enum GameStatus {
        case RUNNING
        case STOPPED
        case PAUSED
    }
    
    var nextGeneration: [(Int,Int)] = []
    var currentGeneration: [(Int,Int)] = []
    
    var lastIndexAllowed:Int {
        get {
            return worldSize-1
        }
    }
    
    // REMARK: run current generation and prepare next.
    func runGeneration() {
        // erase born and life arrays
        nextGeneration = []
        // validate current
        for creature in currentGeneration {
            // display currentGeneration
            validateLife(line:creature.0, col:creature.1)
            // check my empty neighbours if they can get life
            for cell in getNeighboursIndexes(x:creature.0, y:creature.1) {
                
                let line = cell.0
                let col  = cell.1
                
                if !world[line][col].square.live {
                    validateLife(line:line, col:col)
                }
                
            }
        }
        // clean all current positions after validated
        for creature in currentGeneration {
            world[creature.0][creature.1].change(false)
        }
        // only remains for the next
        for creature in nextGeneration {
            // display nextGeneration
            world[creature.0][creature.1].change(true)
        }
        // swap arrays for next generation
        currentGeneration = nextGeneration
    }
    
    func toggleCell(line: Int, col: Int) {
        let cell = world[line][col]
        if cell.square.live {
            cell.change(false)
        } else {
            cell.change(true)
        }
        currentGeneration.append((line, col))
    }
    
    // check who is alive
    func validateLife(line:Int,col:Int) {
        // 1. less than 2 neighbours alive dies
        // 2. two or more alive neighbours alive lives for the next generation
        // 3. more than 3 neighbours dies
        // 4. if exactly 3 alive and its empty turns alive.
        let alive: Bool = world[line][col].square.live
        let neighboursAlive: Int = getNeighbours(x:line, y:col)
        if alive {
            if neighboursAlive >= 2 && neighboursAlive <= 3 {
                // don't need to do nothing its already alive
                nextGeneration.append((line, col))
            }
            
        } else {
            // REMARK: needs to run.
            if neighboursAlive == 3 {
                // reproduction mark to born
                nextGeneration.append((line, col))
            }
        }
    }
    // REMARK: Initialize the world
    func initWorld() {
       /* for row in 0 ..< worldSize {
            var squareRow:[Square] = []
            for col in 0 ..< worldSize {
                let square = Square(row: row, col: col)
                squareRow.append(square)
            }
            world.append(squareRow)
        } */
    }
    
    func resetBoard() {
        // assign mines to squares
        for row in 0 ..< worldSize {
            for col in 0 ..< worldSize {
                world[row][col].square.live = false
            }
        }
        
    }
    
    // REMARK: get indexes at neighbours if its out ouf bounds we can get at begin or in the end of world.
    func getNeighboursIndexes(x:Int, y:Int) -> [(Int,Int)] {
        let xMin1 = x-1 < 0 ? lastIndexAllowed :x-1
        let xPlu1 = x+1 > lastIndexAllowed ? 0 : x+1
        let yMin1 = y-1 < 0 ? lastIndexAllowed : y-1
        let yPlu1 = y+1 > lastIndexAllowed ? 0 : y+1
        let arr = [
            (xMin1, yMin1),(x, yMin1),(xPlu1, yMin1),
            (xMin1, y),           (xPlu1, y),
            (xMin1, yPlu1),(x, yPlu1),(xPlu1, yPlu1)
        ]
        
        return arr
    }
    
    // REMARK: return all neighbours for x and y
    func getNeighbours(x:Int, y:Int) -> Int {
        let arr = getNeighboursIndexes(x:x, y:y)
        var sum: Int = 0
        for cell in arr {
            
            let line = cell.0
            let col  = cell.1
            
            sum = sum + (world[line][col].square.live ? 1 : 0)
            
        }
        return sum
    }
}
