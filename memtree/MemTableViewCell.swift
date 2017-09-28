//
//  MemTableViewCell.swift
//  memtree
//
//  Created by Gareth Harris on 11/30/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit

class MemTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!    
    @IBOutlet var img: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
