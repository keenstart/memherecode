//
//  ReportTableViewController.swift
//  MemHere
//
//  Created by Gareth Harris on 2/9/16.
//  Copyright © 2016 Memhere. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol ReportDestinationViewDelegate {
    //func setReport(history: historySettings);
}


class ReportTableViewController: UITableViewController {
    
    @IBOutlet weak var textDescription: UITextView!
    
    var delegate : ReportDestinationViewDelegate! = nil
    var object:PFObject! = nil
    var navColor = UIColor.greenColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = navColor
        
        textDescription.layer.cornerRadius = 8
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelReport(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func reportButton(sender: AnyObject) {
        
        let parseObject = PFObject(className: "Report")
        
        //parseObject["isPrivate"] = privateSwitch.on
        parseObject["reportDescription"] = self.textDescription.text
        
        parseObject["MemID"] = self.object
        parseObject["userWhoCreatedMem"] = self.object["username"]
        parseObject["userWhoCreatedMemID"] = self.object["createdBy"]
        
        parseObject["userWhoReportedMem"] = PFUser.currentUser()!.username!
        parseObject["userWhoReportedMemID"] = PFUser.currentUser()
        
        parseObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success){
                print("Successful Save!")

                //self.dismissViewControllerAnimated(true, completion: nil)
                //self.performSegueWithIdentifier("segueHere", sender: nil)
            }else {
                print(error?.userInfo)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            //self.cancelMem(self)
        }
        
        
    }
    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
*/
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
