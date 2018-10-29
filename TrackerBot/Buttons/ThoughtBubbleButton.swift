//
//  ThoughtBubbleButton.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/12/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit
import SnapKit
import SwiftGifOrigin

class ThoughtBubbleButton: UIButton {
    enum BubbleType {
        case FlashUpdate
        case YesterdayWork
        case TodayWork
    }
    
    var bubbleMessage: Dictionary<BubbleType, String> = [
        BubbleType.FlashUpdate: "What did my project put in the latest release?",
        BubbleType.YesterdayWork: "What did my project do yesterday?",
        BubbleType.TodayWork: "What are my project's open tracks?"
    ]
    
    let messageLabel: UILabel
    
    let bubbleType: BubbleType
    init(bubbleType: BubbleType) {
        self.bubbleType = bubbleType
        self.messageLabel = UILabel()
        super.init(frame: .zero)
        self.setBackgroundImage(UIImage.gif(asset: "LargeThoughtBubbleGif"), for: UIControlState.normal)
        self.messageLabel.text = self.bubbleMessage[self.bubbleType]
        self.messageLabel.lineBreakMode = .byWordWrapping
        self.messageLabel.numberOfLines = 3
        self.messageLabel.font = UIFont.systemFont(ofSize: 10, weight: 1)
        self.messageLabel.textAlignment = NSTextAlignment.center
        self.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(self.snp.width).multipliedBy(0.7)
            make.center.equalTo(self.snp.center)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
