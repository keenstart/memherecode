//
//  CaptionTableViewCell.swift
//  memhere
//
//  Created by Gareth Harris on 11/26/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit

class CaptionTableViewCell: UITableViewCell {

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
