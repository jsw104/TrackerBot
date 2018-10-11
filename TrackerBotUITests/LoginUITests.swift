//
//  TrackerBotUITests.swift
//  TrackerBotUITests
//
//  Created by Justin Wang on 10/9/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import XCTest

class LoginUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        
        // We send a command line argument to our app,
        // to enable it to reset its state
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginFormIsDisplayedOnLaunch() {
        app.launch()
        let emailField = app.textFields["emailField"]
        let passwordField = app.textFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        // Onboarding should no longer be displayed
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)
    }
}
