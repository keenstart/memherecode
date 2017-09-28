//
//  RecentMemTableViewController.swift
//  memhere
//
//  Created by Gareth Harris on 10/15/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class RecentMemTableViewController: UITableViewController {
    var memObjects:Array<AnyObject> = Array<AnyObject>()
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var cntPrivate:Int = 0
    
    var navColor = UIColor.greenColor()
    var labelmsg:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Memhere"
        self.navigationController?.navigationBar.barTintColor = navColor
        
        // Message label
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.labelmsg = UILabel(frame: CGRectMake(0, 0, screenWidth, screenHeight)) //200, 21
        self.labelmsg.center = CGPointMake(screenWidth/2, screenHeight/2) //160, 284
        self.labelmsg.textAlignment = NSTextAlignment.Center
        self.labelmsg.textColor = UIColor.blueColor()
        self.labelmsg.font = UIFont(name: self.labelmsg.font.fontName, size: 16)
        self.labelmsg.text = "No Mems to Edited."
        self.view.addSubview(self.labelmsg!)
        
        self.labelmsg.hidden =  true
    }

    override func viewWillAppear(animated: Bool) {
        showLoadingMem()
        
    }
    
    func showLoadingMem(){
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        indicator.hidesWhenStopped = true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchAllObjectsFromCloud()
    }
    
    func fetchAllObjectsFromCloud(){
        
        //Create a date from today two weeks ago
        let twoWeeksAgo = NSDate(timeIntervalSinceNow: Double(-60*60*24*14))
        print(twoWeeksAgo)
        
        //Create a query
        let query = PFQuery(className: "Mem")
        
        //Specify the predicate for the query
        //query.orderByDescending("createdAt")
        query.orderByAscending("createdAt")
        query.whereKey("createdBy", equalTo:PFUser.currentUser()!)
        query.whereKey("timestamp", greaterThanOrEqualTo: twoWeeksAgo)
        query.whereKey("isDeleted", notEqualTo: true)
        
        
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error: NSError?) -> Void in
            // If no error returned
            if error == nil{
                //The query succeded. Debug Log how many objects it found
                print("Successfully retried \(objects!.count) mems.")
                
                //If the optional has data, set the memObjects variable to queried objects
                if let objects = objects as? [PFObject] {
                    self.memObjects = objects
                }
                
                //Refresh UI Elements
                self.getPrivateCount()
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                
                
            } else {
                print(error!.userInfo)
            }
            
            if(self.memObjects.count == 0){
                self.labelmsg.hidden = false
            }else{
                self.labelmsg.hidden = true
            }
            
            self.tableView.reloadData()
        }
        

    }
    
    func timeRemaining(timestamp:NSDate) ->String{
  
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone() //NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
        
        let date = timestamp //NSDate()
        let now = NSDate()

        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day,.Hour,.Minute,], fromDate:date ,toDate:now,options: [])

        let days = components.day
        let hour = components.hour
        let minutes = components.minute
        
        //---- Debug
        let fromdate = dateFormatter.stringFromDate(date)
        let dateto = dateFormatter.stringFromDate(now)
        print("Day: \(days), hour: \(hour), minutes: \(minutes) . now: \(fromdate) ")
        print("Day: \(13 - days), hour: \(23 - hour), minutes: \(59 - minutes) . now: \(dateto) ")
        print(now)
        print(timestamp)
        ///----

        let remainingtime:String = "D:\(13 - days) H:\(23 - hour) M:\(59 - minutes) Left"

        return  remainingtime
    
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.memObjects.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        print("Rows in tableview \(self.memObjects.count)")
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            return self.view.bounds.height - 136
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Create new object for the cells from the array
        let object:PFObject = self.memObjects[indexPath.section] as! PFObject
        
        let imageFile:PFFile = object["image"] as! PFFile
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let date = object["timestamp"] as! NSDate
        let isPrivate:Bool = object["isPrivate"] as! Bool
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! HeaderTableViewCell
            cell.usernameLabel.text = object["username"] as? String
            
            cell.daysRemaining.text = timeRemaining(date)
            
            return cell
        } else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageViewTableViewCell
            imageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if error == nil{
                    if let imageData = imageData {
                        cell.cellImageView.image = UIImage(data: imageData)
                        
                    }
                }
                }, progressBlock: { (Int32) -> Void in
                    //                var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    //                indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    //                indicator.center = self.view.center
                    //                self.view.addSubview(indicator)
                    //                self.view.bringSubviewToFront(indicator)
                    //                indicator.startAnimating()
                    //                indicator.stopAnimating()
            })
            return cell
            
        } else if (indexPath.row == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("timestampCell", forIndexPath: indexPath) as! TimestampTableViewCell
            
            cell.cellTimeStampLabel.text = dateFormatter.stringFromDate(date)
            let tag:Int = (indexPath.row+1)+(indexPath.section*100)
            
            cell.deleteButton.tag = tag
            cell.deleteButton.addTarget(self, action: "findMem:", forControlEvents: UIControlEvents.TouchUpInside)
 
            print("isPrivate: \(isPrivate)\n")
            print("self.cntPrivate: \(self.cntPrivate)\n")
            
            if (isPrivate == false){
                if(self.cntPrivate  > 0){
                    
                    cell.isPrivateButton.hidden = true
                    cell.privateButton.hidden = false
                    
                    cell.privateButton.tag = indexPath.section
                    cell.privateButton.addTarget(self, action: "makePrivate:", forControlEvents: UIControlEvents.TouchUpInside)

                    cell.totalPrivate.text = "\(self.cntPrivate )"
                    print("cntPrivate: \(self.cntPrivate )\n")

                }else{
                    print("Private is Zero\n")

                    cell.totalPrivate.text = "0"
                    cell.privateButton.hidden = false
                    cell.isPrivateButton.hidden = true
                }
            }else{
                cell.totalPrivate.text = "(P)"
                cell.isPrivateButton.hidden = false
                cell.privateButton.hidden = true
                
                print("is Private\n")
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("captionCell", forIndexPath: indexPath) as! CaptionTableViewCell
            
            cell.captionLabel.text = object["caption"] as? String
            return cell
            
        }
    }
    
    func noPrivate() {
        let title = "No Private"
        let message = "Private count as run out. For this period"
        let okAlert = "OK"
       
        let alert = UIAlertController(title:title, message: message,preferredStyle: UIAlertControllerStyle.Alert)
        
        let okButton = UIAlertAction(title: okAlert, style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okButton)
        
        presentViewController(alert, animated:true, completion:nil)
    
    }
    
    func makePrivate(button: UIButton) {
        let mem = memObjects[button.tag] as! PFObject
        let caption = mem["caption"] as! String
        print("Check caption: \(caption) n")
        
        let optionMenu = UIAlertController(title: nil, message: "Make Mem Private?", preferredStyle: .ActionSheet)
        
        let likeAction = UIAlertAction(title: "Private", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            if( self.cntPrivate != 0){
                self.makeMemPrivate(mem)
                mem["isPrivate"] = true

                self.cntPrivate = self.cntPrivate - 1
            }else{
                 self.noPrivate()
            }
            print("email cntPrivate \(self.cntPrivate)\n") //debug
           
            
            self.tableView.reloadData()
        }
        
        let cancelActionDel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            self.tableView.reloadData()
            print("Cancelled")
        }
        
        optionMenu.addAction(likeAction)
        optionMenu.addAction(cancelActionDel)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    
    }
    
    func getPrivateCount(){
        PFCloud.callFunctionInBackground("getPrivateCounting", withParameters: ["iUser":""]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if (error == nil){
                self.cntPrivate = (response as? Int)!
                self.tableView.reloadData()
                print("cntPrivate cloud: \(self.cntPrivate)\n")
            }
        }
        
        
    }
    
    func makeMemPrivate(mem:PFObject){
        let objId:String = mem.objectId!
        
        PFCloud.callFunctionInBackground("MarkMemasPrivate", withParameters:["mem":objId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("Check response: \(response)")
                 self.getPrivateCount()
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }

    func findMem(button: UIButton) {
       let indexPath = getIndexPathFromTag(button.tag)
        
        print("The Button Section is \(indexPath.section)")
        let mem = memObjects[indexPath.section] as! PFObject
        let query = PFQuery(className: "Mem")
        
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you with to delete this Mem?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            query.getObjectInBackgroundWithId(mem.objectId!, block: { (object: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error?.userInfo)
                } else if let object = object {
                    
                    print("\nDeleting: \(mem.objectId!)")
                    object["isDeleted"] = true
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success {
                        print("\nDeleted: \(mem.objectId!) successfully")
                        self.fetchAllObjectsFromCloud()
                        } else {
                            print(error?.userInfo)
                        }
                    })
                    
                }
            })
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
       
    }

    
    func getIndexPathFromTag(tag:Int) -> NSIndexPath {
        var row:Int = 0
        var section:Int = 0
        for (var i = 100; i<tag; i+=100){
            section++
        }
        row = tag - (section*100)
        row--
        
        return NSIndexPath(forRow: row, inSection: section)
    }

}