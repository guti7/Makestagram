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
    
    // MARK: - Users
    
    /**
     Fetch all users, except the one that's currently signed in.
     Limits the amount of users returned to 20.
     :param:    completionBlock The completion block that is called when the query completes
     :returns:  the generated PFQuery
    */
    static func allUsers(completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        let query = PFUser.query()! // Parse adds this functionality to PFUser class
        // exclude the current user
        query.whereKey(ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        // FIXME: Order Ascending case insensitive
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    /**
     Fetch users whose usernames match the provided search term.
     :param: searchText The text that should be used to search for users.
     :param: completionBlock The completion block that is called when the query completes.
     :returns: The generated PFQuery
    */
    static func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        /*
         NOTE: We are using a Regex to allow for a case insentitive compare of usernames.
         Regex can be slow on large databases. For large amount of data it's better to
         store lowercased username in a separate column and perform a regular string compare.
        */
        
        let query = PFUser.query()!
        query.whereKey(ParseHelper.ParseUserUsername, matchesRegex: searchText, modifiers: "i")
        query.whereKey(ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
        
    }
    
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
        likeObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    } // likePost()
    
    static func unlikePost(user: PFUser, post: Post) {
        let query = PFQuery(className: ParseLikeClass) // gets a query for all Like objects
        query.whereKey(ParseLikeFromUser, equalTo: user) // updates query for likes from user
        query.whereKey(ParseLikeToPost, equalTo: post) // updates query of likes from user to the post
        // query should result in one post by this line
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            // FIXME: Which on is it? 'as? [PFObject]' part 2 sect 4 E.H.Callback
            if let results = results {
                for like in results { // like is PFObject
                    like.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
                }
            }
        }
    } // unlikePost()
    
    
    // MARK: Following
    
    /**
     Fetches all users that the provided user is following.
     :param: user The user whose followees you want to retrieve
     :param: completionBlock The completion block that is called where the query completes
    */
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
     Establishes a follow relationship between two users.
     :param: user   The user that is following.
     :param: toUser The user that is being followed.
    */
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    }
    
    /**
     Deletes a follow relationship between two users.
     :param: user   The user that is following
     :param: toUser The user that is being followed
    */
    static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.whereKey(ParseFollowToUser, equalTo: toUser) // one
        
        query.findObjectsInBackgroundWithBlock {
            (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            let results = results ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
            }
        }
    } // removeFollowRelationshipFromUser()
    
} // class

// MARK: Extensions

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
}
