//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Guti on 6/26/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit // get TimelineComponent

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    // MARK: Properties
    
    // Defines how many posts to load initially
    let defaultRange = 0...4
    // Defines how many additional posts to load once the bottom timeline is reached
    let additionalRangeSize = 5
    
    // array of Posts
    var posts: [Post] = []
    
    // Referance to UITableView
    @IBOutlet weak var tableView: UITableView!
    // it won't be initilized until the proper selection is made by the user
    var photoTakingHelper: PhotoTakingHelper?
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self
        
    }
    
    // Loads certain portion of the timeline and call the completionBlock
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            let posts = result as? [Post] ?? []
            completionBlock(posts)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timelineComponent.loadInitialIfRequired()
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
        return 1
    }
    
    // TODO: Added this without being sure where it goes.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
//        cell.postImageView.image = posts[indexPath.row].image
        let post = timelineComponent.content[indexPath.section]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
        
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        timelineComponent.targetWillDisplayEntry(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostSectionHeaderView
        
        let post = self.timelineComponent.content[section]
        headerCell.post = post
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
