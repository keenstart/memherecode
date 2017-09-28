//
//  HeaderTableViewCell.swift
//  memhere
//
//  Created by Gareth Harris on 11/26/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
 
    @IBOutlet weak var daysRemaining: UILabel!
    
    //@IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userProfilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
