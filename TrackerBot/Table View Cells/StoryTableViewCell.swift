//
//  StoryTableViewCell.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/15/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
    @IBOutlet var storyTitleLabel: UILabel!
    @IBOutlet var estimateLabel: UILabel!
    @IBOutlet var labelsLabel: UILabel!
    @IBOutlet var storyTypeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureFor(story:Story) {
        storyTitleLabel.text = story.name
        if story.labels != nil {
            labelsLabel.text = story.labels.joined(separator: ", ")
        }
        estimateLabel.text = (story.estimate != nil) ? String(story.estimate!) : "unestimated"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
