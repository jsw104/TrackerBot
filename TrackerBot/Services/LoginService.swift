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
    func login(apiToken: String!)
}

// Delegate for the LoginService
protocol LoginServiceDelegate {
    func loginSuccessfull(withUser user: User, project: Project)
    func handle(error: String)
}


// The class is responsible to validate the input
// parameters and consequently hit the login api
class LoginServiceHandler: LoginService {
    let delegate: LoginServiceDelegate
    
    init(delegate: LoginServiceDelegate) {
        self.delegate = delegate
    }
    
    func login(apiToken: String!) {
        let path: String = "v5/me"
        let host: String = "www.pivotaltracker.com"
        let urlString: String = "https://" + host + "/services/" + path
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiToken, forHTTPHeaderField: "X-TrackerToken")
        request.addValue("Yes", forHTTPHeaderField: "X-Tracker-Use-UTC")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        login(request: request)
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
        login(request: request)
    }
    
    func login(request: URLRequest!) {
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
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    self.saveJSONToCoreData(appDelegate: appDelegate, json: json!)
                    let currentUser: User? = appDelegate.userForUserId(userId: (UserDefaults.standard.value(forKey: "currentUserId") as! Int))
                    let currentProject: Project? = appDelegate.projectForProjectId(projectId: (UserDefaults.standard.value(forKey: "currentProjectId") as! Int))
                    if (currentUser == nil || currentProject == nil) {
                        self.delegate.handle(error: "error retrieving user from core data")
                    } else {
                        self.delegate.loginSuccessfull(withUser: currentUser!, project: currentProject!)
                    }

                }
            }
        }
        
        task.resume()
    }
    
    func saveJSONToCoreData(appDelegate:AppDelegate, json:Dictionary<String, Any>) -> Void {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        self.overwriteExistingUser(userId: json["id"] as! Int, context: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(json["username"], forKey: "username")
        newUser.setValue(json["api_token"], forKey: "apiToken")
        newUser.setValue(json["id"], forKey: "id")
        newUser.setValue(json["name"], forKey: "name")
        newUser.setValue(json["email"], forKey: "email")
        
        let projectEntity = NSEntityDescription.entity(forEntityName: "Project", in: context)
        let projects: Array<AnyObject> = json["projects"] as! Array<AnyObject>
        for project in projects {
            self.overwriteExistingProjects(projectId: project["project_id"] as! Int, context: context)
            let newProject = NSManagedObject(entity: projectEntity!, insertInto: context)
            newProject.setValue(project["project_id"] as Any?, forKey: "id")
            newProject.setValue(project["project_name"] as Any?, forKey: "projectName")
            newUser.mutableSetValue(forKey: "projects").add(newProject)
        }
        do {
            try context.save()
            UserDefaults.standard.set(newUser.value(forKey: "id") as! Int, forKey: "currentUserId")
            UserDefaults.standard.set((newUser.value(forKeyPath: "projects") as! Set<Project>).first!.value(forKey: "id") as! Int, forKey: "currentProjectId")
        } catch {
            print("Failed saving")
        }
    }
    
    func overwriteExistingUser (userId: Int, context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id = %d", userId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for user in result {
                context.delete(user as! User)
            }
        } catch {
        }
    }
    
    func overwriteExistingProjects (projectId: Int, context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        request.predicate = NSPredicate(format: "id = %d", projectId)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for project in result {
                context.delete(project as! Project)
            }
        } catch {
        }
    }
}


