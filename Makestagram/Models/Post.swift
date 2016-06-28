//
//  Post.swift
//  Makestagram
//
//  Created by Guti on 6/27/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

// Custom Parse Class 
// inherit PFObject and implement PFSubclassing protocol
class Post: PFObject, PFSubclassing {
    
    // properties
    @NSManaged var imageFile: PFFile? // @ tells the compiler that we won't initilize it in init
    @NSManaged var user: PFUser?  // Parse takes care of this
    
    var image: Observable<UIImage?> = Observable(nil) // needs to be Observable
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    
    //MARK: PFSbubclassing Protocol
    
    // Creates a connection between the Parse class and Swift class
    static func parseClassName() -> String {
        return "Post"
    }
    
    // Boelerplate code
    override init() {
        super.init()
    }
    
    // Boilerplate code
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    // download post
    func downloadImage() {
        // if not downloaded yet, get it
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                }
            }
        }
    }
    
    // uploadPost
    func uploadPost() {
        
        if let image = image.value {
            
            // guard is like iptional binding used to unwrap optionals
            // we watnt to execute some code when the variable doesn't exist
            guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            // if cant initialize then just exist method ^^
            
            // add user
            self.user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                
            }
            
            saveInBackgroundWithBlock() { (sucess: Bool, error: NSError?) in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
}
