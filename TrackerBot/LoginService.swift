//
//  LoginManager.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/10/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

protocol LoginService {
    var delegate: LoginServiceDelegate { get }
    func login(email: String!, password: String!)
}

// Delegate for the LoginService
protocol LoginServiceDelegate {
    
    func loginSuccessfull(withUser user: String)
    
    func handle(error: String)
}


// The class is responsible to validate the input
// parameters and consequently hit the login api
class LoginServiceHandler: LoginService {
    let delegate: LoginServiceDelegate
    
    init(delegate: LoginServiceDelegate) {
        self.delegate = delegate
    }
    
    func login(email: String!, password: String!) {
        let basicAuthCredentials: String = email + ":" + password
        let base64encodedAuthCredentials: String = "Basic " + Data(basicAuthCredentials.utf8).base64EncodedString()
        let path: String = "v5/me"
        let host: String = "www.pivotaltracker.com"
        let urlString: String = "https://" + host + "/services/" + path
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(base64encodedAuthCredentials, forHTTPHeaderField: "Authorization")
        request.setValue("Yes", forHTTPHeaderField: "X-Tracker-Use-UTC")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        request.setValue("iOS " + appVersion, forHTTPHeaderField: "X-Tracker-Client")
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
        delegate.loginSuccessfull(withUser: "user")
    }
}

