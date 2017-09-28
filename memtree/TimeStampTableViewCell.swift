//
//  FooterTableViewCell.swift
//  memhere
//
//  Created by Gareth Harris on 11/26/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit

class TimestampTableViewCell: UITableViewCell {

  

    
    //@IBOutlet weak var likesCount: UITextField!


    

    @IBOutlet weak var likeCounts: UILabel!
    @IBOutlet weak var totalPrivate: UILabel!
    //@IBOutlet weak var totalField: UITextField!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var didlikeButton: UIButton!
    @IBOutlet weak var isPrivateButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
   // @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellTimeStampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
