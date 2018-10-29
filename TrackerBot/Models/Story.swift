//
//  Story.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/15/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

class Story: NSObject {
    let estimate: Int?
    let name: String
    let id: Int
    let storyType: String
    let labels: [String]
    let ownerIds: [Int]?
    let currentState: String

    init(estimate: Int?, name: String, id: Int, storyType: String, labels: [String], ownerIds:[Int]?, currentState: String) {
        self.estimate = estimate
        self.name = name
        self.id = id
        self.storyType = storyType
        self.labels = labels
        self.ownerIds = ownerIds
        self.currentState = currentState
    }
}
