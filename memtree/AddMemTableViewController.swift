//
//  AddMemTableViewController.swift
//  memhere
//
//  Created by Gareth Harris on 10/15/15.
//  Copyright (c) 2015 Memhere. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

protocol AddDestinationViewDelegate {
    func setRefresh(refresh: Bool);
}

class AddMemTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate : AddDestinationViewDelegate! = nil
    
    //Variables
    var imagePicker = UIImagePickerController()
    
    var image:UIImage?
    var location: PFGeoPoint!
    var caption: String!
    var radius: Float!
    var timestamp: NSDate!
    var resizedImage:UIImage?
    
    var saveOnce:Bool!
    
    //Outlets
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    //@IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var memImageView: UIImageView!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var rangeSliderLabel: UILabel!
    
    var navColor = UIColor.greenColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = navColor
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.saveOnce = true
        
        self.navigationController?.navigationBar.hidden = false

        //If no image data pop up camera
        
        if self.image == nil{
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(self.imagePicker, animated: false, completion: nil)
            print("Didnt")
        } else {
            print("Now calling config view")
            configureView()
        }
       
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.memImageView.image = self.image
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        configureView()
    }
    
    //Function for image picture delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.cancelMem(self)
       
    }

    func returnParentView(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func configureView() {
        //Set min max for slider
        rangeSlider.minimumValue = 100.0
        rangeSlider.maximumValue = 1000.0
        let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.memImageView.image = scaledImage
        
        //Get the current location
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.location = geoPoint!
                print("\(self.location) on \(NSDate())")
            }
        })
    }

    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    // MARK: - Table view data source
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let imageBounds = self.view.bounds
            return imageBounds.height - 180
        }
        return 25
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }
    @IBAction func rangeSliderChanged(sender: AnyObject) {
        self.rangeSliderLabel.text = String(format: "%.2f", self.rangeSlider.value)
    }

    @IBAction func saveMem(sender: AnyObject) {
        
        if(self.saveOnce == true){
            self.saveOnce = false
            
            self.radius = self.rangeSlider.value
            self.timestamp = NSDate()
            self.caption = self.captionTextField.text
        
            let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.25, 0.25))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        
        
            //
            let imageData:NSData = UIImageJPEGRepresentation(scaledImage!, 0)!
            let imageFile = PFFile(name:"image.jpg", data:imageData)
        
            let parseObject = PFObject(className: "Mem")
        
            //parseObject["isPrivate"] = privateSwitch.on
            parseObject["username"] = PFUser.currentUser()!.username!
            parseObject["createdBy"] = PFUser.currentUser()
            parseObject["caption"] = caption
            parseObject["image"] = imageFile
            parseObject["radius"] = radius
            parseObject["location"] = location
            parseObject["timestamp"] = timestamp
        
            parseObject["isPrivate"] = false
            parseObject["isDeleted"] = false
            parseObject["numLikes"] = 0
        
            parseObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if(success){
                    print("Successful Save!")
                    self.delegate.setRefresh(true)
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    //self.performSegueWithIdentifier("segueHere", sender: nil)
                }else {
                    print(error?.userInfo)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
                //self.cancelMem(self)
            }
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelMem(sender: AnyObject) {
        self.delegate.setRefresh(false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
