//
//  ViewControllerUITests.swift
//  ViewControllerUITests
//
//  Created by Jose on 25/03/2018.
//  Copyright © 2018 Jose. All rights reserved.
//

import XCTest

class ViewControllerUITests: XCTestCase {
    
    var app: XCUIApplication!
    private var launched = false

    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        launchIfNecessary()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }
    
    private func launchIfNecessary() {
        if !launched {
            launched = true
            // app.launchEnvironment = ["animations": "0"]
            app.launch()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testToggle() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.children(matching: .button).element(boundBy: 101).tap()
        elementsQuery.children(matching: .button).element(boundBy: 102).tap()
        elementsQuery.children(matching: .button).element(boundBy: 202).tap()
        elementsQuery.children(matching: .button).element(boundBy: 201).tap()
        elementsQuery.children(matching: .button).element(boundBy: 303).tap()
        elementsQuery.children(matching: .button).element(boundBy: 304).tap()
        elementsQuery.children(matching: .button).element(boundBy: 404).tap()
        elementsQuery.children(matching: .button).element(boundBy: 403).tap()
    }
    
}
