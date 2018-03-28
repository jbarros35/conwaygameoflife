//
//  ConwayGame.swift
//  ConwayPrj
//
//  Created by Jose on 22/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import Foundation

enum GameStatus {
    case RUNNING
    case STOPPED
    case STABLE
    case OVER
    case PAUSED
}

protocol ConwayGamePtcl {
    
    typealias T = GameStatus
    
    var gameStatus:GameStatus? {get}
    var generations: Int {get set}
    var nextGeneration: [(Int,Int)] {get}
    var currentGeneration: [(Int,Int)] {get}
    var staleGeneration: [(Int,Int)] {get} // fix erasing.
    var generationsHistory: [String] {get}
    var worldSize: Int {get set}
    
    func changeStatus(status: T)
    func runGeneration()
    func toggleCell(line: Int, col: Int)
    func appendCurrentGeneration(line:Int, col: Int)
    func getCurrentSize() -> Int
    func getCellAt(row: Int, col: Int) -> Bool
    
}

class ConwayGame: ConwayGamePtcl {

    var world: [[Bool]] = []
    var worldSize: Int = 0
    var generations: Int = 0
    var staleGeneration: [(Int,Int)] = []
    internal var nextGeneration: [(Int,Int)] = []
    internal var currentGeneration: [(Int,Int)] = []
    internal var generationsHistory: [String]
    var gameStatus: GameStatus?
    
    init(worldSize: Int) {
        // print("init game world \(worldSize)")
        generationsHistory = []
        self.worldSize = worldSize
        // initialize world array
        for _ in 0..<worldSize {
            var line: [Bool] = []
            for _ in 0..<worldSize {
                line.append(false)
            }
            world.append(line)
        }
    }
    
    var lastIndexAllowed:Int = 0
    
    // REMARK: run current generation and prepare next.
    func runGeneration() {
        gameStatus = .RUNNING
        lastIndexAllowed = worldSize-1
        generations = generations + 1
        if currentGeneration.isEmpty {
            gameStatus = .OVER
            return
        }
        
        if !generationsHistory.contains("\(currentGeneration)") {
            if generationsHistory.count >= 5 {
                generationsHistory.removeFirst()
            }
            generationsHistory.append("\(currentGeneration)")
            staleGeneration = currentGeneration
        } else {
            gameStatus = .STABLE
            return
        }
        
        // erase born and life arrays
        nextGeneration.removeAll()
        // validate current
        for creature in currentGeneration {
            // display currentGeneration
            validateLife(line:creature.0, col:creature.1)
            // check my empty neighbours if they can get life
            for cell in getNeighboursIndexes(x:creature.0, y:creature.1) {
                let line = cell.0
                let col  = cell.1
                if !world[line][col] {
                    validateLife(line:line, col:col)
                }
            }
        }
        // clean all current positions after validated
        for creature in currentGeneration {
            world[creature.0][creature.1] = false
        }
        currentGeneration.removeAll()
        // only remains for the next
        for creature in nextGeneration {
            // display nextGeneration
            world[creature.0][creature.1] = true
        }
        
        // swap arrays for next generation
        currentGeneration = nextGeneration
        nextGeneration.removeAll()
    }
    
    func changeStatus(status: GameStatus) {
        gameStatus = status
    }
    
    // check who is alive
    func validateLife(line:Int,col:Int) {
        // 1. less than 2 neighbours alive dies
        // 2. two or more alive neighbours alive lives for the next generation
        // 3. more than 3 neighbours dies
        // 4. if exactly 3 alive and its empty turns alive.
        let alive: Bool = world[line][col]
        let neighboursAlive: Int = getNeighbours(x:line, y:col)
        // print("validation \(line, col), alive: \(alive), neighbours active: \(neighboursAlive)")
        if alive {
            if neighboursAlive >= 2 && neighboursAlive <= 3 {
                // don't need to do nothing its already alive
                appendNextGeneration(line:line,col:col)
            }
            
        } else {
            // REMARK: it runs on empty cells
            if neighboursAlive == 3 {
                // reproduction mark to born
                appendNextGeneration(line:line,col:col)
            }
        }
    }
    // REMARK: when a button is pressed adds or removes from world
    func toggleCell(line: Int, col: Int) {
        let cellState = world[line][col]
        if cellState {
            // exists
            world[line][col] = false
            removeCurrentGeneration(line: line, col: col)
        } else {
            // new to current
            world[line][col] = true
            appendCurrentGeneration(line: line, col: col)
        }
    }
    
    func getCellAt(row: Int, col: Int) -> Bool {
        return world[row][col]
    }
    
    func appendCurrentGeneration(line:Int, col: Int) {
        let index = currentGeneration.index{$0 == line && $1 == col}
        if index == nil {
            // print("append to current: \(line, col)")
            currentGeneration.append((line, col))
        }
    }
    // REMARK: get current size on current generation
    public func getCurrentSize() -> Int {
        return currentGeneration.count
    }
    
    func removeCurrentGeneration(line:Int, col: Int) {
        if let index = currentGeneration.index(where: {$0 == line && $1 == col}) {
            currentGeneration.remove(at: index)
        }
    }

    func appendNextGeneration(line:Int, col: Int) {
        let index = nextGeneration.index{$0 == line && $1 == col}
        if index == nil {
            // print("append to next: \(line, col)")
            nextGeneration.append((line, col))
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
    
    // REMARK: return all neighbours cells for x and y
    func getNeighbours(x:Int, y:Int) -> Int {
        let arr = getNeighboursIndexes(x:x, y:y)
        var sum: Int = 0
        for cell in arr {
            let line = cell.0
            let col  = cell.1
            sum = sum + (world[line][col] ? 1 : 0)
        }
        return sum
    }
}
