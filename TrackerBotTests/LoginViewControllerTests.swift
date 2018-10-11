//
//  LoginViewControllerTests.swift
//  TrackerBotTests
//
//  Created by Justin Wang on 10/10/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import Nimble
import XCTest
@testable import TrackerBot

class FakeLoginServiceHandler: LoginServiceHandler {
    var loginCalled: Bool = false
    override func login(email: String?, password: String?) {
        loginCalled = true
    }
}

class LoginViewControllerTests: XCTestCase {

    //let loginViewController: LoginViewController = UIStoryboard.instantiateInitialViewController(UIStoryboard(name: "Main", bundle: nil)) as! LoginViewController
    let loginViewController: LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
    override func setUp() {
        _ = loginViewController.view // To call viewDidLoad
        loginViewController.loginService = FakeLoginServiceHandler(delegate: loginViewController)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginServiceCalled() {
        loginViewController.emailField.text = "failure@example.com"
        loginViewController.passwordField.text = "password"
        loginViewController.loginPressed(self)
        expect((self.loginViewController.loginService as! FakeLoginServiceHandler).loginCalled).to(equal(true))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
