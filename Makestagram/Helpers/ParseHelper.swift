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
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        
        // create the Query object to use to search for matches in database
        let followingQuery = PFQuery(className: "Follow")
        
        // Add constraint using fromUser properity 
        // - which equals to currentUser -- fromUser is the "follower"
        // the currentUser's list of follwing users
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        // get the Query object for "Post" class
        // toUser in Follow is the followed
        let postsFromFollowedUsers = Post.query()
        // constrain the Query by matches what the "user" is following
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        // agregate both Query lists
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey("user")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    } // timelineRequestFCU()
} // class











