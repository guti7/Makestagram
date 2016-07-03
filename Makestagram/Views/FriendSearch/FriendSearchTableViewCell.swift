//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Guti on 7/2/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

class FriendSearchTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    // MARK: Actions
    @IBAction func followButtonTapped(sender: AnyObject) {
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
