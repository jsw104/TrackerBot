//
//  TrackerBotService.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/12/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

protocol TrackerBotService {
    var delegate: TrackerBotServiceDelegate { get }
    func getAllStoriesInProgress(project: Project, user: User)
    func getAllStoriesFromYesterday(project: Project, user: User)
    func getAllStoriesInCurrentRelease(project: Project, user: User)
}

// Delegate for the LoginService
protocol TrackerBotServiceDelegate {
    func retrieveYesterdayWorkSuccessful(stories: [Story])
    func retrieveInProgressWorkSuccessful(stories: [Story])
    func handle(error: String)
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

class TrackerBotServiceHandler: TrackerBotService {
    let delegate: TrackerBotServiceDelegate
    let user: User
    var project: Project
    init(user: User, project: Project, delegate: TrackerBotServiceDelegate) {
        self.user = user
        self.project = project
        self.delegate = delegate
    }
    
    func getAllStoriesInCurrentRelease(project: Project, user: User) {
        let urlString: String = "https://www.googleapis.com/storage/v1/b/deploy-spy/o/production_commits.json?alt=media"
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            var json: Dictionary<String, Any> = Dictionary()
            do {
                json = try (JSONSerialization.jsonObject(with: data, options: [])) as! Dictionary<String, Any>
            } catch {
                DispatchQueue.main.async {
                    self.delegate.handle(error: "error parsing json")
                }
            }
            DispatchQueue.main.async {
                var parameters: String = "ids="
                for story in json {
                    parameters.append(story.key + "%2C")
                }
                parameters.append("2%2C0")
                self.getStoriesWithParams(params: parameters, project: project, user: user,subpath: "/stories/bulk?")
            }
        }
        
        task.resume()
    }
    
    /*
        gets all stories finished delivered or accepted during the previous work day
    */
    func getAllStoriesFromYesterday(project: Project, user: User) {
        let stringFromDate = Date().addingTimeInterval(TimeInterval(-86400)).iso8601
        let parameters: String = "updated_after=" + stringFromDate
        getStoriesWithParams(params: parameters, project: project, user: user, subpath: "/stories?")
    }
    
    func getAllStoriesInProgress(project: Project, user: User) {
        let parameters: String = "with_state=" + "started"
        getStoriesWithParams(params: parameters, project: project, user: user, subpath: "/stories?")
    }
    
    func getStoriesWithParams(params: String, project: Project, user: User, subpath: String) -> Void {
        let path: String = "v5/projects/"
        let host: String = "www.pivotaltracker.com"
        let urlString: String = "https://" + host + "/services/" + path + String(project.value(forKey: "id") as! Int) + subpath + params
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(user.value(forKey: "apiToken") as! String, forHTTPHeaderField: "X-TrackerToken")
        request.addValue("Yes", forHTTPHeaderField: "X-Tracker-Use-UTC")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        request.addValue("iOS " + appVersion, forHTTPHeaderField: "X-Tracker-Client")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else { return }
            var json: [Dictionary<String, Any>] = []
            do {
                json = try (JSONSerialization.jsonObject(with: data, options: [])) as! [Dictionary<String, Any>]
                print(json)
            } catch {
                DispatchQueue.main.async {
                    self.delegate.handle(error: "error parsing json")
                }
            }
            DispatchQueue.main.async {
                var stories: [Story] = []
                for story in json {
                    var labels: [String] = []
                    var jsonLabels: [Dictionary<String, Any>]?
                    jsonLabels = (story["labels"] as? [Dictionary<String, Any>])
                    if (jsonLabels != nil) {
                        for label in jsonLabels! {
                            labels.append(label["name"] as! String)
                        }
                    }
                    stories.append(Story(estimate: story["estimate"] as? Int, name: story["name"] as! String, id: story["id"] as! Int, storyType: story["story_type"] as! String, labels: labels, ownerIds: story["owner_ids"] as? [Int]))
                }
                self.delegate.retrieveYesterdayWorkSuccessful(stories: stories)
            }
        }
        
        task.resume()
    }
    
}
