//
//  BotViewController.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/11/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import SnapKit
import DeckTransition
import SideMenu
import CoreData

class Position: NSObject {
    var x: Float
    var y: Float
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
        super.init()
    }
}

class Size: NSObject {
    var width: Float
    var height: Float
    init(width: Float, height: Float) {
        self.width = width
        self.height = height
        super.init()
    }
}

class BotViewController: UIViewController {
    let thoughtBubbleButtonSize: Size = Size(width: 100, height: 100)
    let trackerBotButtonSize: Size = Size(width: 225/3.0, height: 215/3.0)
    let user:User
    var project:Project
    let trackerBotButton: TrackerBotButton
    var trackerBotService: TrackerBotService!
    let thoughtButtons: [ThoughtBubbleButton]
    let yesterdayWorkButton: ThoughtBubbleButton
    let todayWorkButton: ThoughtBubbleButton
    let flashUpdateButton: ThoughtBubbleButton
    let headerContainerView: UIView
    let projectTitleLabel: UILabel
    let openSideMenuButton: UIButton
    
    init (user: User, project: Project) {
        self.user = user
        self.project = project
        self.trackerBotButton = TrackerBotButton()
        self.yesterdayWorkButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.YesterdayWork)
        self.todayWorkButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.TodayWork)
        self.flashUpdateButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.FlashUpdate)
        self.thoughtButtons = [yesterdayWorkButton, todayWorkButton, flashUpdateButton]
        self.openSideMenuButton = UIButton()
        self.headerContainerView = UIView()
        self.projectTitleLabel = UILabel()
        super.init(nibName: nil, bundle: nil)
        
        self.openSideMenuButton.addTarget(self, action: #selector(self.openSideMenuButtonClicked(sender:)), for: .touchUpInside)
        for thoughtButton in self.thoughtButtons {
            thoughtButton.addTarget(self, action: #selector(self.thoughtButtonClicked(sender:)), for: .touchUpInside)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerBotService = TrackerBotServiceHandler(user: user, project: project, delegate: self)
        self.view.backgroundColor = UIColor.black
        layoutTrackerBotButton()
        layoutThoughtButtons()
        layoutHeader()
        layoutSideMenu()
        // Do any additional setup after loading the view.
    }
    
    func layoutHeader() {
        self.view.addSubview(headerContainerView)
        headerContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerContainerView.superview!.snp.top).offset(20)
            make.width.equalTo(headerContainerView.superview!.snp.width)
            make.height.equalTo(64)
        }
        self.headerContainerView.backgroundColor = UIColor.black
        self.headerContainerView.addSubview(openSideMenuButton)
        openSideMenuButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.left.equalTo(20)
            make.top.equalTo(20)
        }
        self.headerContainerView.addSubview(projectTitleLabel)
        projectTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(projectTitleLabel.superview!.snp.centerX)
            make.centerY.equalTo(openSideMenuButton.snp.centerY)
            make.left.equalTo(openSideMenuButton.snp.right)
        }
        projectTitleLabel.text = self.project.projectName
        projectTitleLabel.textAlignment = NSTextAlignment.center
        projectTitleLabel.textColor = UIColor.white
        openSideMenuButton.backgroundColor = UIColor.red
    }
    
    func getUserProjectsFromCoreData(completionBlock: ([Project]) -> Void) -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id = %d", user.id)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for user in result {
                completionBlock(Array((user as! User).projects!) as! [Project])
                return
            }
        } catch {
        }
    }
    
    func layoutSideMenu() {
        getUserProjectsFromCoreData { (projects) in
            let sideMenuController = SideMenuTableViewController(currentProject: self.project, projects: projects, delegate: self)
            let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: sideMenuController)
            SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
            SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        }
    }
    
    func layoutTrackerBotButton() {
        self.view.addSubview(trackerBotButton)
        trackerBotButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(trackerBotButtonSize.width)
            make.height.equalTo(trackerBotButtonSize.height)
            make.center.equalTo(self.view)
        }
    }
    
    func layoutThoughtButtons() {
        self.view.addSubview(yesterdayWorkButton)
        yesterdayWorkButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(20)
            make.bottom.lessThanOrEqualTo(trackerBotButton.snp.top).offset(-15)
        }
        self.view.addSubview(todayWorkButton)
        todayWorkButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(-20)
            make.height.equalTo(yesterdayWorkButton.snp.height)
            make.bottom.equalTo(yesterdayWorkButton.snp.top)
            make.top.equalTo(self.view).offset(44)
        }
        self.view.addSubview(flashUpdateButton)
        flashUpdateButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(yesterdayWorkButton.snp.height)
            make.left.equalTo(20)
            make.bottom.equalTo(self.view).offset(-50)
        }
    }
    
    func openSideMenuButtonClicked(sender: UIButton) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func thoughtButtonClicked(sender: UIButton){
        let bubbleType : ThoughtBubbleButton.BubbleType = (sender as! ThoughtBubbleButton).bubbleType
        switch bubbleType {
        case ThoughtBubbleButton.BubbleType.FlashUpdate:
            self.trackerBotService.getAllStoriesInCurrentRelease(project: project, user: user)
        case ThoughtBubbleButton.BubbleType.YesterdayWork:
            self.trackerBotService.getAllStoriesFromYesterday(project: project, user: user)
        case ThoughtBubbleButton.BubbleType.TodayWork:
            self.trackerBotService.getAllStoriesInProgress(project: project, user: user)
        }
    }
}

extension BotViewController: ProjectSelectionServiceDelegate {
    func selectedProject(project: Project) {
        self.project = project
        UserDefaults.standard.set(project.id, forKey: "currentProjectId")
        self.projectTitleLabel.text = self.project.projectName
        dismiss(animated: true, completion: nil)
    }
}

extension BotViewController: TrackerBotServiceDelegate {
    func retrieveInProgressWorkSuccessful(stories: [Story]) {
        for story in stories {
            print(story.name)
        }
        let modal = StoriesTableViewController(stories: stories)
        let transitionDelegate = DeckTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        present(modal, animated: true, completion: nil)
    }
    
    func retrieveYesterdayWorkSuccessful(stories: [Story]) {
        for story in stories {
            print(story.name)
        }
        let modal = StoriesTableViewController(stories: stories)
        let transitionDelegate = DeckTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        present(modal, animated: true, completion: nil)
    }
    
    func handle(error: String) {
        let alert = UIAlertController(title: "Authentication Error.", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
