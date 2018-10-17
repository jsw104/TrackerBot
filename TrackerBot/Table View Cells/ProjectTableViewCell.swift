//
//  ProjectTableViewCell.swift
//  TrackerBot
//
//  Created by Justin Wang on 10/17/18.
//  Copyright © 2018 Justin. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet var projectTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Initialization code
    }
    
    func configureFor(project:Project, currentProject: Bool) {
        projectTitleLabel.text = project.projectName
        if (currentProject == true) {
            self.contentView.layer.borderColor = UIColor.white.cgColor
        } else {
            self.contentView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}
