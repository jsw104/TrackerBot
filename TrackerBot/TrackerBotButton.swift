//
//  TrackerBotButton.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/10/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

class TrackerBotButton: UIButton {


    override func draw(_ rect: CGRect) {
        self.setBackgroundImage(UIImage(named: "TrackerBot"), for: UIControlState.normal)
    }

}
