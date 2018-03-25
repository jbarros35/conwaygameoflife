//
//  ConwayGameTest.swift
//  ConwayGameTest
//
//  Created by Jose on 25/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import XCTest
@testable import ConwayPrj

class ConwayGameTest: XCTestCase {
    
    var game: ConwayGame!
    let framewidth: CGFloat = 200.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        game = ConwayGame()
        game.worldSize = 10
        var world = game.world
        let worldSize = game.worldSize
        for row in 0 ..< worldSize {
            var line:[SquareButton] = []
            for col in 0 ..< worldSize {
                
                let square: SquareButton = ViewController.buttonSquare(row: row, col: col, frameWidth: framewidth, worldSize: worldSize).squareButton
                
                // self.myView.addSubview(square)
                // self.squareButtons.append(square)
                line.append(square)
            }
            // append line of squares to game
            world.append(line)
        }
        game.world = world
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFillWorld() {
        XCTAssertEqual(game.getCurrentSize(), 0)
    }
    
    func testToggleCell() {
        game.toggleCell(line: 0, col: 0)
        game.toggleCell(line: 1, col: 0)
        game.toggleCell(line: 2, col: 0)
        XCTAssertEqual(game.getCurrentSize(), 3)
        // test disable cells
        game.toggleCell(line: 0, col: 0)
        game.toggleCell(line: 1, col: 0)
        game.toggleCell(line: 2, col: 0)
        XCTAssertEqual(game.getCurrentSize(), 0)
    }
    
    func testRunGeneration() {
        game.toggleCell(line: 0, col: 0)
        game.toggleCell(line: 1, col: 0)
        game.toggleCell(line: 2, col: 0)
        game.runGeneration()
        XCTAssertEqual("\(game.currentGeneration)", "\([(1, 9), (1, 1), (1, 0)])")
        XCTAssertEqual("\(game.nextGeneration)", "\([])")
    }
    
    func testEmptyGeneration() {
        game.toggleCell(line: 0, col: 0)
        game.runGeneration()
        game.runGeneration()
        XCTAssertEqual("\(game.currentGeneration)", "\([])")
        XCTAssertEqual("\(game.gameStatus!)", "OVER")
    }
    
    func testGameStable() {
        game.toggleCell(line: 0, col: 0)
        game.toggleCell(line: 1, col: 0)
        game.toggleCell(line: 2, col: 0)
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        XCTAssertEqual("\(game.gameStatus!)", "STABLE")
    }

    func testFiveGenerationsBeyond() {
        // put a glider
        game.toggleCell(line: 2, col: 0)
        game.toggleCell(line: 2, col: 1)
        game.toggleCell(line: 2, col: 2)
        game.toggleCell(line: 1, col: 2)
        game.toggleCell(line: 0, col: 1)
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        XCTAssertEqual("\(game.gameStatus!)", "RUNNING")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
