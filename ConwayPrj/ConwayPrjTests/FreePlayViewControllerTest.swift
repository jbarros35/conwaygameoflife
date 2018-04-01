//
//  ViewControllerTest.swift
//  ConwayPrjTests
//
//  Created by Jose on 25/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import XCTest
@testable import ConwayPrj

class FreePlayViewControllerTest: XCTestCase {
    
    var controller: FreePlayViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier: "FreePlayViewController") as! FreePlayViewController
        _ = controller.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        controller = nil
    }
    
    func squareCell() -> SquareCell {
        let cell = SquareCell(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        cell.live = false
        return cell
    }
    
    func testRUNNING() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 0))
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 1))
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 2))
        controller.startNewGame()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .RUNNING)
        controller.startNewGame()
    }
    
    func testDidSelectItemAt() {
        // override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        controller.collectionView((self.controller?.collectionView!)!, didSelectItemAt: IndexPath(row: 0, section: 0))
     //    XCTAssertEqual(controller.gameLogic?.getCellAt(row: 0, col: 0), true)
    }
    
    func testSTABLE() {
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 0)) // on
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 1))
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 2))
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 0)) // off
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 0)) // on again
        controller.startNewGame()
        controller.advanceGeneration()
        controller.advanceGeneration()
        controller.advanceGeneration()
        controller.advanceGeneration()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .STABLE)
        controller.advanceGeneration()
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 2))
    }
    
    func testOVER() {
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 2))
        controller.startNewGame()
        controller.advanceGeneration()
        controller.advanceGeneration()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .OVER)
        controller.startNewGame()
        controller.advanceGeneration()
        controller.changeButton(cell: squareCell(), indexPath: IndexPath(row: 0, section: 2))
        controller.startNewGame()
    }
    
    func testINVALIDSTATE() {
        controller.startNewGame()
        XCTAssertEqual(controller.gameLogic?.gameStatus, .STOPPED)
        controller.startNewGame()
        controller.startNewGame()
    }
    
}
