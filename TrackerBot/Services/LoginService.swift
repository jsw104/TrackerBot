//
//  LoginManager.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/10/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import CoreData

protocol LoginService {
    var delegate: LoginServiceDelegate { get }
    func login(email: String!, password: String!)
}

// Delegate for the LoginService
protocol LoginServiceDelegate {
    
    func loginSuccessfull(withUser user: User)
    
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
        request.addValue(base64encodedAuthCredentials, forHTTPHeaderField: "Authorization")
        request.addValue("Yes", forHTTPHeaderField: "X-Tracker-Use-UTC")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        request.addValue("iOS " + appVersion, forHTTPHeaderField: "X-Tracker-Client")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            var json:Dictionary<String, Any>? = Dictionary()
            do {
                json = try (JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>)
            } catch {
                DispatchQueue.main.async {
                    self.delegate.handle(error: "error parsing json")
                }
            }
            if(json?["error"] != nil) {
                DispatchQueue.main.async {
                    self.delegate.handle(error: json!["error"]! as! String)
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate.loginSuccessfull(withUser: self.saveJSONToCoreData(json: json!))
                }
            }
        }
        
        task.resume()
    }
    
    func saveJSONToCoreData(json:Dictionary<String, Any>) -> User {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(json["username"], forKey: "username")
        newUser.setValue(json["api_token"], forKey: "apiToken")
        newUser.setValue(json["id"], forKey: "id")
        newUser.setValue(json["name"], forKey: "name")
        newUser.setValue(json["email"], forKey: "email")
        do {
            try context.save()
            UserDefaults.standard.set(newUser.value(forKey: "id"), forKey: "currentUserId")
        } catch {
            print("Failed saving")
        }
        return newUser as! User
    }
    
}


