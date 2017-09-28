//
//  MemTableViewController.swift
//  memtree
//
//  Created by Gareth Harris on 10/30/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MemsViewController: UIViewController , PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate,
        CLLocationManagerDelegate, UISearchBarDelegate,
        UITableViewDelegate, UITableViewDataSource,
        DestinationViewDelegate,
        AddDestinationViewDelegate,
        ReportDestinationViewDelegate
{
    
    @IBOutlet var tableView: UITableView!
    

    @IBOutlet weak var memSearchBar: UISearchBar!
    
    @IBOutlet weak var historyButton: UIButton!
    
    var object:PFObject!
    var indexMem:Int!
    
    var currentLocation:PFGeoPoint!
    var memObjects:Array<AnyObject> = Array<AnyObject>()
    var getmemObjects:Array<AnyObject> = Array<AnyObject>()
    
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var currentMemCount:Int!
    var currentMemPage:Int!
    
    let memPageSize:Int = 25 // 25 //This value should be the same in the cloud (skip)
    
    var navColor = UIColor.greenColor()
    var reFreshControl:UIRefreshControl!
    
    var history : historySettings!
    
    //Creates Log in view controller
    let logInViewController:PFLogInViewController! = PFLogInViewController()
    let signUpViewController:PFSignUpViewController! = PFSignUpViewController()
    

    var msgbutton:UIButton!// = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 300))//width: screenWidth, height: screenHeight
    var agreeButton : UIButton!
    var agreeButtonLogin : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentMemCount = 0
        self.currentMemPage = 0
        
        self.memSearchBar.text = ""
        self.history = historySettings()
        
        self.navigationController?.navigationBar.barTintColor = navColor
        
        self.tabBarController?.tabBar.translucent = false
        self.navigationController?.navigationBar.translucent = false
        history = historySettings()
        //Pull to Refresh
        self.reFreshControl = UIRefreshControl()
        self.reFreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.reFreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        self.tableView.addSubview(self.reFreshControl!)
       
        // Message button
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        self.msgbutton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.33))//width: screenWidth, height: screenHeight
        self.msgbutton.center = CGPointMake(screenWidth/2, screenHeight/2) //160, 284
        //msgbutton.backgroundColor = UIColor.blueColor()
        self.msgbutton.setTitle("No Mems Here. Tap to make some.\n Or Change your search and date period", forState: .Normal)
        self.msgbutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.msgbutton.addTarget(self, action: "invokeMemCapture:", forControlEvents: .TouchDown)
        self.msgbutton.hidden = false
        
        self.view.addSubview(self.msgbutton!)
        
        resetMem()
    }
    
    override func viewWillAppear(animated: Bool) {
        //showLoadingMem()mkxc
        historyButtonTitle()
    }
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
 
        // Agree button
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        
        logInViewController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten, PFLogInFields.DismissButton]
        
        // Add Logo
        let loginLogoTitle = UILabel()
        loginLogoTitle.text = "MemHere"
        loginLogoTitle.textColor = navColor
        loginLogoTitle.font = UIFont(name: loginLogoTitle.font.fontName, size: 50)
        

        logInViewController.logInView?.dismissButton?.hidden = true
        logInViewController.logInView?.logo = loginLogoTitle
        //--
        self.agreeButtonLogin = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
        self.agreeButtonLogin.center = CGPointMake(screenWidth * 0.50,screenHeight)
        //self.agreeButtonLogin.backgroundColor = UIColor.greenColor()
        self.agreeButtonLogin.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.agreeButtonLogin.setTitle("I AGREE to the terms of use. Click to view.", forState: .Normal)
        self.agreeButtonLogin.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.agreeButtonLogin.addTarget(self, action: "viewTerms:", forControlEvents: .TouchDown)


        
        logInViewController.logInView?.addSubview(self.agreeButtonLogin)//
        //--
        logInViewController.delegate = self
        
        
        let SigninLogoTitle = UILabel()
        SigninLogoTitle.text = "MemHere"
        SigninLogoTitle.textColor = navColor
        SigninLogoTitle.font = UIFont(name: SigninLogoTitle.font.fontName, size: 50)
        
        signUpViewController.signUpView?.logo = SigninLogoTitle
        signUpViewController.delegate = self
        //---

        
        self.agreeButton  = UIButton(type: UIButtonType.System) as UIButton
        self.agreeButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.agreeButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.agreeButton.setTitle("I AGREE to the terms of use. Click to view.", forState: UIControlState.Normal)
        self.agreeButton.bounds = CGRect(x: 0, y: 0, width: screenWidth, height: 20)
        self.agreeButton.center = CGPointMake(screenWidth * 0.50,screenHeight * 1.10)
        //self.agreeButton.backgroundColor = UIColor.greenColor()
        self.agreeButton.addTarget(self, action:"viewTerms:", forControlEvents:UIControlEvents.TouchUpInside)

        signUpViewController.view.addSubview(self.agreeButton)
        //---
        logInViewController.signUpController = signUpViewController
        
        if(PFUser.currentUser() == nil){
            self.presentViewController(logInViewController, animated: true, completion: nil)
            
        }
        

        if(self.getmemObjects.count == 0){
            // Display Empty Message
            self.msgbutton.hidden = false
            historyButtonTitle(false)
        }
    }
    
    func viewTerms(button: UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.memhere.com/mem/tou")!)
    }
    
    func invokeMemCapture(button: UIButton){
        print("I'am a test label\n")
        // Stop Request camera if not empty //
        if(self.memObjects.count == 0){
            let rightbarButtonItem = navigationItem.rightBarButtonItem
            UIApplication.sharedApplication().sendAction(rightbarButtonItem!.action, to: rightbarButtonItem!.target, from: self, forEvent: nil)
        }
    }
    
    // MARK: - HistoryPeriod Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "historySegue") {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! HistoryPeriodController
            //addEventViewController.newTagArray = newTagArray

            
            //let destination = segue.destinationViewController as! HistoryPeriod
            destination.delegate = self
            destination.hpHistory = historySettings()
            destination.hpHistory.myMems = self.history.myMems
            destination.hpHistory.currentTimes = self.history.currentTimes
            destination.hpHistory.fromDate = self.history.fromDate
            destination.hpHistory.toDate = self.history.toDate
            
        }
        
        if (segue.identifier == "captureMems") {
            let nav = segue.destinationViewController as! UINavigationController
            let destinationAdd = nav.topViewController as! AddMemTableViewController

            destinationAdd.delegate = self
        }
        
        if (segue.identifier == "reportSegue") {
            let nav = segue.destinationViewController as! UINavigationController
            let destinationReport = nav.topViewController as! ReportTableViewController
            
            destinationReport.delegate = self
            destinationReport.object = self.memObjects[self.indexMem] as! PFObject
        }
        
    }
    
    func setHistory(history: historySettings) {
        print("hpHistory.myMems : \(history.myMems)\n")
        print("hpHistory.currentTimes: \(history.currentTimes)\n")
        
        print("hpHistory.fromDate: \(history.fromDate)\n")
        print("hpHistory.toDate: \(history.toDate)\n")
        
        self.history.fromDate = history.fromDate
        self.history.toDate = history.toDate
        self.history.currentTimes = history.currentTimes
        self.history.myMems = history.myMems

        historyButtonTitle()
        refresh(self)
    }
    
    func setRefresh(refresh: Bool) {
        if(refresh){
            resetMem()
        }
    }
    
    func historyButtonTitle(help:Bool = true) {
        var title:String!
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        if(help){
            if(!self.history.currentTimes){
                if(self.history.myMems){
                    title = "My Mems before \(dateFormatter.stringFromDate(self.history.fromDate)) in History."
                }else{
                    title = "All Mems before \(dateFormatter.stringFromDate(self.history.fromDate)) in History."
                }
            }else{
            
                if(self.history.myMems){
                    title = "My Mems before Now."
                }else{
                    title = "All Mems before Now."
                }
            }
        }else{
            title = "Press Here to go Back in Time."
        }
        
        
        self.historyButton.setTitle(title, forState: UIControlState())
    }
    
    // MARK: - Reset Function
    func showLoadingMem(){
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        indicator.hidesWhenStopped = true
    }
    
    func resetMempages(){
        self.currentMemCount = 0
        self.currentMemPage = 0
        self.getmemObjects.removeAll(keepCapacity: false)
    }
    
    func refresh(sender: AnyObject){
        print("Pull to refresh")
        
        resetMempages()
        fetchAllObjectsFromLocalDatastore(self.memSearchBar.text!)
        
    }
    
    // New User login or change user on devices
    func resetMem(){
        resetMempages()
        self.memObjects.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        fetchAllObjectsFromLocalDatastore("")
        print("Reset")
        
    }

    //This needs to go onto the cloud
    func fetchAllObjectsFromLocalDatastore(searbarText: String){
        
        //Function queries location through Parse geopoint api
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {

                //Assign geopoint to class variable
                self.currentLocation = geoPoint!
                print("Current GeoPoint: \(self.currentLocation)")
                print("searbarText: \(searbarText)")
                
                
                PFCloud.callFunctionInBackground("getMemsInRadius", withParameters:["longitude":geoPoint!.longitude, "latitude":geoPoint!.latitude, "numOfMems":self.currentMemPage,"searchBar":searbarText,"fromdate":self.history.fromDate,"todate":self.history.toDate,"mymem":self.history.myMems,"now":self.history.currentTimes]) {
                    (response: AnyObject?, error: NSError?) -> Void in
                    
                    if error == nil {

                        if let response = response as? [PFObject] {
                            // Loop through array and make only objects within radius part of array for tableview
                            for object in response {
                                //object["nlike"] = object["numLikes"]
                                object["ilike"] = -1
                                self.getmemObjects.append(object)
                            }
                            
                        }
                        //--------
                        self.memObjects = self.getmemObjects
                        print("Check: \(self.memObjects)")
                        
                        //Refresh the table view
                        self.tableView.reloadData()
                        
                        if(self.memObjects.count != 0){
                            self.msgbutton.hidden = true
                        }else{
                            self.msgbutton.hidden = false
                        }
                        
                        //Stop the loading indicator
                        self.indicator.stopAnimating()
                        self.reFreshControl.endRefreshing()
                    }else{
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            }})
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections
        return self.memObjects.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        print("Rows in tableview \(self.memObjects.count)")
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            return self.view.bounds.height - 136
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        memSearchBar.resignFirstResponder()
        print("resignFirstResponder touch")
        return indexPath
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentUser = PFUser.currentUser()
        
        var intervalHelpMsg:Bool = false
        
        //Create new object for the cells from the array
        //let object:PFObject = self.memObjects[indexPath.section] as! PFObject
        
        self.object = self.memObjects[indexPath.section] as! PFObject

        
        let imageFile:PFFile = self.object["image"] as! PFFile
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let date = self.object["timestamp"] as! NSDate
        
        let likecnt = self.object["numLikes"] as! Int
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! HeaderTableViewCell
            cell.usernameLabel.text = self.object["username"] as? String
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
            self.indexMem = indexPath.section
            
            let cell = tableView.dequeueReusableCellWithIdentifier("timestampCell", forIndexPath: indexPath) as! TimestampTableViewCell
            
            cell.cellTimeStampLabel.text = dateFormatter.stringFromDate(date)
            
            cell.likeButton.tag = indexPath.section
            cell.likeButton.addTarget(self, action: "likeMem:", forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeCounts.text = String(likecnt)
            
            let ilike: Int  = object["ilike"] as! Int
            //-----
            if(ilike == -1 && currentUser != nil){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { // 1
                    //Check if current user like the Mem //
                    let query = PFQuery(className:"Likes")
                    query.whereKey("mems", equalTo:self.object)
                    query.whereKey("userWhoLike", equalTo:currentUser!)
                    
                    //let islike = query
                    let islike = query.countObjects()
                    print("islike : \(islike)\n")
                    if(islike == 0){
                        self.object["ilike"] = 0
                    }else{
                        self.object["ilike"] = 1
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        //Refresh the table view
                        self.tableView.reloadData()
                    })
                })
            }

            if(ilike == 1){
                cell.likeButton.hidden = true
                cell.didlikeButton.hidden = false
                
            }else{
                cell.likeButton.hidden = false
                cell.didlikeButton.hidden = true
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("captionCell", forIndexPath: indexPath) as! CaptionTableViewCell
            
            cell.captionLabel.text = object["caption"] as? String
            
            if (indexPath.section >= self.memObjects.count - 1  ){//indexPath.row|| indexPath.section == self.memObjects.count - 5
                
                //If less that memObjects count a new page of mem as arrived
                if(self.currentMemCount < self.memObjects.count){
                    
                    self.currentMemCount = self.memObjects.count
                    self.currentMemPage = self.currentMemPage + self.memPageSize
                    
                    fetchAllObjectsFromLocalDatastore(self.memSearchBar.text!)
                    
                }
            }
            
            //Show help and history period with interval //
            if(indexPath.section % 2 == 0){
                intervalHelpMsg = !intervalHelpMsg
            }
            
            if(intervalHelpMsg){
                historyButtonTitle(false)
            }else{
                historyButtonTitle()
            
            }
        
            return cell
        }
    }
    
    // MARK: - Icon Buttons
    
    func likeMem(button: UIButton) {
        let mem = memObjects[button.tag] as! PFObject
        let caption = mem["caption"] as! String
        print("Check: \(caption)\n")
        
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to PERMANENTLY LIKE this Mem?", preferredStyle: .ActionSheet)
        
        let likeAction = UIAlertAction(title: "Like", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            
            self.addLikes(mem)
            
            //Increment like count
            var nlike = mem["numLikes"] as! Int
            nlike++
            
            mem["numLikes"] = nlike
            
            // Change the ilike value in memObject
            mem["ilike"] = 1
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        }
        
        optionMenu.addAction(likeAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func addLikes(mem:PFObject){
        let objId:String = mem.objectId!
        
        PFCloud.callFunctionInBackground("IncrementLikes", withParameters:["mem":objId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error == nil {
                print("Check: \(response)")
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    // MARK: - SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        memSearchBar.resignFirstResponder()
        
        resetMempages()
        fetchAllObjectsFromLocalDatastore(memSearchBar.text!)
        
    }
    
    // MARK: - Login and Signup
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if(!username.isEmpty || !password.isEmpty){
            return true
        } else {
            return false
        }
    }
    
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        resetMem()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        
        if let password = info["password"] as? String {
            return password.utf16.count >= 5
            /*
            if (password.utf16.count >= 8){
                return true
            }else{
                let title = "Password Error!"
                let msg = "Password should be eight alphanumeric character in length."
                let okError = "OK"
                
                let alert = UIAlertController(title:title, message:msg, preferredStyle: UIAlertControllerStyle.Alert)
                let okay = UIAlertAction(title: okError, style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okay)
                
                presentViewController(alert, animated: true,completion: nil)
                return false
            }*/
            //return true
            
        } else {
            return false
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        resetMem()
        resetPrivateCount()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Failed to sign up!")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("User dismissed sign up")
    }
    
    // Remove null in privateCount
    func resetPrivateCount(){
            PFCloud.callFunctionInBackground("getPrivateCounting", withParameters: ["iUser":""]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if (error == nil){

            }
        }
    }
    
    
}
