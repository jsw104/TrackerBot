//
//  TrackerBotTests.swift
//  TrackerBotTests
//
//  Created by Justin Wang on 9/26/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import Nimble
import XCTest
@testable import TrackerBot

class TrackerBotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        expect(1 + 1).to(equal(2))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
