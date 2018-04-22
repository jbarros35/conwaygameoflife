//
//  ConwayGameTest.swift
//  ConwayGamePrjTests
//
//  Created by Jose on 22/04/2018.
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
        game = ConwayGame(worldSize: 10)
    }
    
    func testFillWorld() {
        XCTAssertEqual(game.world.count, 10)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func testGameRepeats() {
        game.toggleCell(line: 0, col: 0)
        game.toggleCell(line: 1, col: 0)
        game.toggleCell(line: 2, col: 0)
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        game.runGeneration()
        XCTAssertEqual("\(game.currentGeneration)", "\([(0, 0), (2, 0), (1, 0)])")
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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
}
