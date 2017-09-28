//
//  SettingsTableViewController.swift
//  memhere
//
//  Created by Gareth Harris on 10/16/15.
//  Copyright (c) Memhere. All rights reserved.
//

import UIKit
import Parse

class SettingsTableViewController: UITableViewController {

    

    var navColor = UIColor.greenColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = navColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    
    
    @IBAction func termOfUse(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.memhere.com/mem/tou")!)
    }
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if error == nil{
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
}
