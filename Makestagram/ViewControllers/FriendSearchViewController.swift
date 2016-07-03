//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by Guti on 6/26/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class FriendSearchViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Stores all the users that match the current search query
    var users: [PFUser]?
    
    /*
     This is a local cache. It stores all the users this user is following.
     It is used to update the UI immediately upon user interaction, instead of
     having to wait for a server response.
    */
    var followingUsers: [PFUser]? {
        didSet { // property observer
            /**
             The list of following users may be fetched after the tableview has
             displayed cells. In this case, we reload the data to reflect 
             "following" status.
             */
            tableView.reloadData()
        }
    }
    
    // The current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests. You
            // can use oldValue to access the previous value of the property.
            oldValue?.cancel()
        }
    }
    
    // This view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // Whenever the state changes, perform one of 
    // the two queries and update the list.
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
            }
        }
    }
    
    // MARK: Update users (list)
    
    /**
     Is called as the completion block of all queries.
     As soon as a query completes, this method updates the Table View.
     */
    func updateList(results: [PFObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
    }
    
    // MARK: View Lifecyle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .DefaultMode
        
        // Fill the cache of a user's followees(the users this user follows)
        ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!) {
            (results: [PFObject]?, error: NSError?) -> Void in
            let relations = results ?? []
            // use map to extract the User being followed from a Follow object
            self.followingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: TableView Data Source

