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
import ConvenienceKit // NSCacheSwift

// Custom Parse Class 
// inherit PFObject and implement PFSubclassing protocol
class Post: PFObject, PFSubclassing {
    
    // properties
    @NSManaged var imageFile: PFFile? // @ tells the compiler that we won't initilize it in init
    @NSManaged var user: PFUser?  // Parse takes care of this
    
    var image: Observable<UIImage?> = Observable(nil) // needs to be Observable
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    var likes: Observable<[PFUser]?> = Observable(nil) // Bond
    static var imageCache: NSCacheSwift<String, UIImage>! // ConvinienceKit
    
    
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
            Post.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
    /*
    * Get the likes to this post (PFUsers)
    */
    func fetchLikes() { // why does this return if it doesn't declare a return value?
        
        if (likes.value != nil) { // already loaded
            return
        }
        
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil } // remove the nil likes
            
            self.likes.value = validLikes?.map { like in let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser // current user who made the post
            }
        })
    } // fetchLikes
    
    /*
    * Returns whether the user is included in the likes array
    */
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value { // is not nil
            return likes.contains(user)
        } else {
            return false
        }
    } // doesUserLikePost
    
    /*
    * Toggle like or unlike post
    */
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // post is liked so unlike it
            likes.value = likes.value?.filter { $0 != user } // remove user from likes list
            ParseHelper.unlikePost(user, post: self)
        } else { // post is not liked
            likes.value?.append(user) // add user to likes array
            ParseHelper.likePost(user, post: self) // update Post in parse
        }
    }
    
    // download post
    func downloadImage() {
        
        image.value = Post.imageCache[self.imageFile!.name]
        // if not downloaded yet, get it
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                    Post.imageCache[self.imageFile!.name] = image
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
                
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
}
