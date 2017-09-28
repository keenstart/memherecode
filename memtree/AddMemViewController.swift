//
//  AddMemViewController.swift
//  memtree
//
//  Created by Gareth Harris  on 8/31/15.
//  Copyright (c) 2015 Parker Skiba. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class AddMemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Create variables needed ie image picker image and parse object
    var imagePicker:UIImagePickerController = UIImagePickerController()
    var image:UIImage?
    var location: PFGeoPoint!
    var caption: String!
    var radius: Float!
    var timestamp: NSDate!
    var resizedImage:UIImage?
    
    //Storyboard Items
    
    @IBOutlet weak var progessBar: UIProgressView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var radiusSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.captionTextField?.placeholder = "Add Caption here.."
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //If there is no image data, popup camera otherwise dont
        if (self.image == nil) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(self.imagePicker, animated: false, completion: nil)
            print("Didnt")
        } else {
            print("Now calling config view")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
                        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
                        self.imgView.image = self.image
                        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
                        configureView()
    }

    //Function for image picture delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.navigationController?.popViewControllerAnimated(false)
        
    }
    

    //Configure UI Elements and grab location
    func configureView() {
        //Set min max for slider
        self.radiusSlider.minimumValue = 50.0
        self.radiusSlider.maximumValue = 1000.0
        let imageSize = CGSize(width: 1080/2, height: 1920/2)
        let rImage: UIImage = scaleImage(image!, newSize: imageSize)
        let data:NSData = UIImagePNGRepresentation(rImage)!
        
        print("size of image \(data.length)")
        
        self.imgView.image = rImage
        
        //Get the current location
        PFGeoPoint.geoPointForCurrentLocationInBackground({ (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.location = geoPoint!
                print("\(self.location) on \(NSDate())")
            }
        })
    }
    
    //Resize image function for upload
    func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        var scaledSize = newSize
        var scaleFactor: CGFloat = 1.0
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.width / image.size.height
            scaledSize.width = newSize.width
            scaledSize.height = newSize.width / scaleFactor
        } else {
            scaleFactor = image.size.height / image.size.width
            scaledSize.height = newSize.height
            scaledSize.width = newSize.width / scaleFactor
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        let scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)
        [image .drawInRect(scaledImageRect)]
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    //Show updated value for slider

    @IBAction func sliderValueChanged(sender: UISlider) {
        self.radiusLabel.text = String(format: "%.0f", self.radiusSlider.value)
    }
    
    @IBAction func saveMem(sender: AnyObject) {
        self.radius = self.radiusSlider.value
        self.timestamp = NSDate()
        self.caption = self.captionTextField.text
        
        let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //
        let imageData:NSData = UIImageJPEGRepresentation(scaledImage!, 0)!
        let imageFile = PFFile(name:"image.jpg", data:imageData)
        
        var parseObject = PFObject(className: "Mem")

        parseObject["username"] = PFUser.currentUser()!.username!
        parseObject["caption"] = caption
        parseObject["image"] = imageFile
        parseObject["radius"] = radius
        parseObject["location"] = location
        parseObject["timestamp"] = timestamp
        
        parseObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success){
                print("Successful Save!")
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                print(error?.userInfo)
            }
        }
        
    }


    @IBAction func cancelButtonFunction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}