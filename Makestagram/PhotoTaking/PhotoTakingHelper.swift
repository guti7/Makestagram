//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Guti on 6/27/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

// "defenition" of a "new type"
// a callback is a referene to a functionn
// a function signature with a name
typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper: NSObject {
    
    // View controller on which AlertViewController and 
    // UIImagePickerController are presented
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    // initializer
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection() {
        // Allow user to choose between photo library and camara 
        let alertController = UIAlertController(title: nil,
                                                message:"Where do you want to" +
                                                         " get your picture from?",
                                                preferredStyle: .ActionSheet);
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
            
            self.showImagePickerController(.PhotoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) {
                (action) in
                
                self.showImagePickerController(.Camera)
                
            }
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
        
        
    } // showPSS() func
    
    // Pick a an image
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        
        
        // set up the delegate property
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!,
                                                  animated: true, completion: nil)
        
    }
    
} // class

extension PhotoTakingHelper: UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
    
    // define protocol methods
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingImage image: UIImage!,
                               editingInfo: [NSObject: AnyObject]!) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
