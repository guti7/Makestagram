//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Guti on 6/27/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import Bond

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    
    // property and property observer
    var post: Post? {
        didSet {
            
            // break old bindings
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    // keyword to avoid the extra { } of the func defenition
                    
                    if let value = value { // value is array of type PFUser
                        self.likesLabel.text = self.stringFromUserList(value)
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        self.likesIconImageView.hidden = (value.count == 0)
                    } else {
                        // default values while waiting for Parse response
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
                
                // bind the image of the post to the 'postImage' view
                post.image.bindTo(postImageView.bnd_image)
                // whenever the value of left hand sid eof .bindTo changes
                // the right hand side gets updated.
            }
        }
    }

    @IBAction func moreButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    /*
     * Generates a comma separated list of usernames from an array
     * (e.g. "User1, User2")
     */
    func stringFromUserList(userList: [PFUser]) -> String {
        let usernameList = userList.map { user in user.username! }
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        return commaSeparatedUserList
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
