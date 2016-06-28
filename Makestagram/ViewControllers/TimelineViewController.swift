//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Guti on 6/26/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    // array of Posts
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // properties
    var photoTakingHelper: PhotoTakingHelper? // it won't be initilized until the proper selection is made by the user

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser {
            // trailing code block/closure
            (result: [PFObject]?, error: NSError?) -> Void in
            
            self.posts = result as? [Post] ?? []
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takePhoto() {
        // instantiate photo taking class, 
        // provide callback for when photo is selected.
        
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            
//            print("received a callback")
            
            let post = Post()
            post.image.value = image
            post.uploadPost()
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController,
                          shouldSelectViewController
                          viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            print("Take Photo")
            takePhoto()
            return false
        } else {
            return true
        }
        
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
//        cell.postImageView.image = posts[indexPath.row].image
        let post = posts[indexPath.row]
        post.downloadImage()
        cell.post = post
        
        return cell
    }
}
