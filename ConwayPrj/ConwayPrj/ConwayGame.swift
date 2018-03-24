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
    public var worldSize: Int = 0
    public var generations: Int = 0
    
    private var nextGeneration: [(Int,Int)] = []
    private var currentGeneration: [(Int,Int)] = []
    private var generationsHistory: [String]
    
    public var gameStatus:GameStatus?
    
    init() {
        generationsHistory = []
    }
    
    enum GameStatus {
        case RUNNING
        case STOPPED
        case STABLE
        case OVER
        case PAUSED
    }
 
    
    var lastIndexAllowed:Int = 0
    
    // REMARK: run current generation and prepare next.
    func runGeneration() {
        lastIndexAllowed = worldSize-1
        generations = generations + 1
        // print(generationsHistory)
        if currentGeneration.isEmpty {
            gameStatus = .OVER
            return
        }
        
        if !generationsHistory.contains("\(currentGeneration)") {
            if generationsHistory.count >= 5 {
                generationsHistory.removeFirst()
            }
            generationsHistory.append("\(currentGeneration)")
        } else {
            gameStatus = .STABLE
            return
        }
        
        // print("world: \(world.count), next: \(nextGeneration.count), current: \(currentGeneration.count), gen: \(generations)")
        // erase born and life arrays
        nextGeneration.removeAll()
        // validate current
        for creature in currentGeneration {
            // display currentGeneration
            validateLife(line:creature.0, col:creature.1)
            // check my empty neighbours if they can get life
            for cell in getNeighboursIndexes(x:creature.0, y:creature.1) {
            // for cell in getNeighboursIndexes(x:creature.col, y:creature.line) {
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
            // world[creature.col][creature.line].change(false)
        }
        currentGeneration.removeAll()
        // only remains for the next
        for creature in nextGeneration {
            // display nextGeneration
            world[creature.0][creature.1].change(true)
            // world[creature.line][creature.col].change(true)
        }
        
        // swap arrays for next generation
        currentGeneration = nextGeneration
        nextGeneration.removeAll()
    }
    
    // check who is alive
    func validateLife(line:Int,col:Int) {
        // 1. less than 2 neighbours alive dies
        // 2. two or more alive neighbours alive lives for the next generation
        // 3. more than 3 neighbours dies
        // 4. if exactly 3 alive and its empty turns alive.
        let alive: Bool = world[line][col].square.live
        let neighboursAlive: Int = getNeighbours(x:line, y:col)
        // print("validation \(line, col), alive: \(alive), neighbours active: \(neighboursAlive)")
        if alive {
            if neighboursAlive >= 2 && neighboursAlive <= 3 {
                // don't need to do nothing its already alive
                appendNextGeneration(line:line,col:col)
            }
            
        } else {
            // REMARK: needs to run.
            if neighboursAlive == 3 {
                // reproduction mark to born
                appendNextGeneration(line:line,col:col)
            }
        }
    }
    
    func toggleCell(line: Int, col: Int) {
        let cell = world[line][col]
        if cell.square.live {
            // exists
            cell.change(false)
            removeCurrentGeneration(line: line, col: col)
        } else {
            // new to current
            cell.change(true)
            appendCurrentGeneration(line: line, col: col)
        }
    }
    
    func appendCurrentGeneration(line:Int, col: Int) {
        let index = currentGeneration.index{$0 == line && $1 == col}
        if index == nil {
            print("append to current: \(line, col)")
            currentGeneration.append((line, col))
        }
    }
    
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
