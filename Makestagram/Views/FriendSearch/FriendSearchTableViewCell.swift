//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Guti on 7/2/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse


// MARK: Protocols

protocol FriendSearchTableViewCellDelegate: class {
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser)
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: FriendSearchTableViewCellDelegate?
    
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
             Change the state of the follow buton based on wheter or not
             it is possible to follow a user.
            */
            if let canFollow = canFollow {
                followButton.selected = !canFollow
            }
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true {
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
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
