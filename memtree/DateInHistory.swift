//
//  DateInHistory.swift
//  MemHere
//
//  Created by Gareth Harris on 10/12/15.
//  Copyright © 2015 Memhere. All rights reserved.
//

import Foundation

struct historySettings {
    var fromDate : NSDate = NSDate()
    var toDate : NSDate = NSDate() //not used
    
    var myMems : Bool = false
    var currentTimes: Bool = true
}