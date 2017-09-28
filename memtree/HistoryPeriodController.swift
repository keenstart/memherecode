//
//  HistoryPeriod.swift
//  MemHere
//
//  Created by Gareth Harris on 10/12/15.
//  Copyright © 2015 Memhere. All rights reserved.
//

import UIKit

protocol DestinationViewDelegate {
    func setHistory(history: historySettings);
}


class HistoryPeriodController:  UITableViewController {

    var delegate : DestinationViewDelegate! = nil
    var hpHistory: historySettings! = nil
    
    var navColor = UIColor.greenColor()

   //let historyInterval: NSTimeInterval = 60 * 15 //15 Minute pickerInterval
    
    @IBOutlet weak var currentMens: UISwitch!
    @IBOutlet weak var myMems: UISwitch!
    
    @IBOutlet weak var ShowSelectedDate: UILabel!
    @IBOutlet weak var datePickerFrom: UIDatePicker!
   // @IBOutlet weak var datePickerTo: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = navColor

        datePickerFrom.addTarget(self, action: "datePickerFromChanged:", forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.ShowSelectedDate.text = dateFormatter.stringFromDate(hpHistory.fromDate)
        
        datePickerFrom.date = hpHistory.fromDate
        
        currentMens.on = hpHistory.currentTimes
        myMems.on = hpHistory.myMems
        
        datePickerFrom.hidden = currentMens.on
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerFromChanged(sender: UIDatePicker){
        //hpHistory.fromDate = datePickerFrom.date
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        self.ShowSelectedDate.text = dateFormatter.stringFromDate(datePickerFrom.date)
    }


    @IBAction func cancelHistory(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveHistory(sender: AnyObject) {
        
        hpHistory.currentTimes = currentMens.on
        hpHistory.myMems = myMems.on
        hpHistory.fromDate = datePickerFrom.date
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        delegate.setHistory(hpHistory)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func currentMemAction(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        if(currentMens.on){
            datePickerFrom.date = NSDate()
            self.ShowSelectedDate.text = dateFormatter.stringFromDate(hpHistory.fromDate)
            
            
        }
        
        datePickerFrom.hidden = currentMens.on
    }
}
