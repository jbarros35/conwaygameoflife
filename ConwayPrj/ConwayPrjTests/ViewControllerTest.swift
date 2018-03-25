//
//  ViewControllerTest.swift
//  ConwayPrjTests
//
//  Created by Jose on 25/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import XCTest
@testable import ConwayPrj


class ViewControllerTest: XCTestCase {
    
    var controller: ViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        controller = UIStoryboard(name: "Main",
                                           bundle: nil).instantiateInitialViewController() as! ViewController!
        _ = controller.view

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        controller = nil
    }
    
    func squareButton(row: Int, col: Int) -> SquareButton {
        let square: SquareButton = ViewController.buttonSquare(row: row, col: col, frameWidth: 1, worldSize: 1).squareButton
        return square
    }
    
    func testRUNNING() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        controller.changeButton(button: squareButton(row: 0, col: 0))
        controller.squareButtonPressed(squareButton(row: 0, col: 1))
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
        controller.newGamePressed()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .RUNNING)
        controller.startNewGame()
    }
    
    func testPAUSE() {
        controller.changeButton(button: squareButton(row: 0, col: 0))
        controller.squareButtonPressed(squareButton(row: 0, col: 1))
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
        controller.newGamePressed()
        // pause game if press some other buttons
        controller.squareButtonPressed(squareButton(row: 1, col: 2))
        XCTAssertEqual(controller.gameLogic?.gameStatus, .PAUSED)
        controller.squareButtonPressed(squareButton(row: 1, col: 3))
        controller.squareButtonPressed(squareButton(row: 1, col: 4))
        controller.startNewGame()
    }
    
    func testSTABLE() {
        controller.changeButton(button: squareButton(row: 0, col: 0)) // on
        controller.squareButtonPressed(squareButton(row: 0, col: 1))
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
        controller.changeButton(button: squareButton(row: 0, col: 0)) // off
        controller.changeButton(button: squareButton(row: 0, col: 0)) // on again
        controller.newGamePressed()
        controller.advanceGeneration()
        controller.advanceGeneration()
        controller.advanceGeneration()
        controller.advanceGeneration()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .STABLE)
        XCTAssertEqual(controller.controlButton?.isOn, false)
        controller.advanceGeneration()
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
    }
    
    func testOVER() {
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
        controller.newGamePressed()
        controller.advanceGeneration()
        controller.advanceGeneration()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .OVER)
        XCTAssertEqual(controller.controlButton?.isOn, false)
        controller.newGamePressed()
        controller.advanceGeneration()
        controller.squareButtonPressed(squareButton(row: 0, col: 2))
        controller.startNewGame()
    }
    
    func testINVALIDSTATE() {
        controller.newGamePressed()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .STOPPED)
        XCTAssertEqual(controller.controlButton?.isOn, false)
        controller.newGamePressed()
        controller.startNewGame()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
