//
//  BotViewController.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/11/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import SnapKit

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
    let trackerBotButton: TrackerBotButton
    let trackerBotService: TrackerBotService
    let thoughtButtons: [ThoughtBubbleButton]
    let yesterdayWorkButton: ThoughtBubbleButton
    let todayWorkButton: ThoughtBubbleButton
    let flashUpdateButton: ThoughtBubbleButton
    
    init (user: User) {
        self.user = user
        self.trackerBotButton = TrackerBotButton()
        self.trackerBotService = TrackerBotService()
        self.yesterdayWorkButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.YesterdayWork)
        self.todayWorkButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.TodayWork)
        self.flashUpdateButton = ThoughtBubbleButton(bubbleType: ThoughtBubbleButton.BubbleType.FlashUpdate)
        self.thoughtButtons = [yesterdayWorkButton, todayWorkButton, flashUpdateButton]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 84/255.0, green: 131/255.0, blue: 174/255.0, alpha: 1)
        layoutTrackerBotButton()
        layoutThoughtButtons()
        // Do any additional setup after loading the view.
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
}
