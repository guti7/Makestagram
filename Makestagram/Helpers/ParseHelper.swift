//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Guti on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    // User Relation constant
    static let ParseUserUsername        = "username"
    
    // Following Relation constants
    static let ParseFollowClass         = "Follow"
    static let ParseFollowFromUser      = "fromUser" // follower - 'follows' - 1st
    static let ParseFollowToUser        = "toUser"   // followed
    
    // Like Relation constants
    static let ParseLikeClass           = "Like"
    static let ParseLikeToPost          = "toPost"
    static let ParseLikeFromUser        = "fromUser"
    
    // Post Relation constants
    static let ParsePostUser            = "user"
    static let ParsePostCreatedAt       = "createdAt"
    
    // Flagged Content Relation constants
    static let ParseFlaggedContentClass     = "FlaggedContent"
    static let ParseFlaggedContentFromUser  = "fromUser"
    static let ParseFlaggedContentToPost    = "toPost"
    
    
    
    // MARK: Timeline
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        
        // create the Query object to use to search for matches in database
        let followingQuery = PFQuery(className: ParseFollowClass)
        
        // Add constraint using fromUser properity 
        // - which equals to currentUser -- fromUser is the "follower"
        // the currentUser's list of follwing users
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        // get the Query object for "Post" class
        // toUser in Follow is the followed
        let postsFromFollowedUsers = Post.query()
        // constrain the Query by matches what the "user" is following
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        // agregate both Query lists
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        query.skip = range.startIndex
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    } // timelineRequestFCU()
    
    // MARK: Likes
    
    /*
    * Finds all the liked related to the given post.
    * Includes the User objects that liked the post.
    * Takes a completion block as a parameter and call when query is done.
    */
    static func likesForPost(post: Post,
                             completionBlock: PFQueryArrayResultBlock) {
        // PFQueryArrayResultBlock - signature: ([PFObject]?, NSError?) -> Void
        
        let likeQuery = PFQuery(className: ParseLikeClass)
        likeQuery.whereKey(ParseLikeToPost, equalTo: post)
        
        likeQuery.includeKey(ParseLikeFromUser)
        
        likeQuery.findObjectsInBackgroundWithBlock(completionBlock)
        // Block can be handed directly to the findObjectsInBWB
        // whoever has called the likesForPost will get the results in 
        // the callback block they provide
    }
    
    static func likePost(user: PFUser, post: Post) {
        // creat a PFObject for parse and store values in the Like Object
        let likeObject = PFObject(className: ParseLikeClass)
        // a Like object has properties fromUser and toPost
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        // save the object to Parse server asynchronously
        likeObject.saveInBackgroundWithBlock(nil)
    } // likePost()
    
    static func unlikePost(user: PFUser, post: Post) {
        let query = PFQuery(className: ParseLikeClass) // gets a query for all Like objects
        query.whereKey(ParseLikeFromUser, equalTo: user) // updates query for likes from user
        query.whereKey(ParseLikeToPost, equalTo: post) // updates query of likes from user to the post
        // query should result in one post by this line
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let results = results {
                for like in results { // like is PFObject
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    } // unlikePost()
} // class

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
}
