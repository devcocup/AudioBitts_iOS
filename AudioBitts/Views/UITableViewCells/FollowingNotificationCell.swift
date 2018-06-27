//
//  FollowingNotificationCell.swift
//  AudioBitts
//
//  Created by Navya on 03/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse

protocol FollowingNotificationCellDelegate: class {
    func followButtonClicked(_ indexPath: IndexPath)
    func profileButtonTapped(_ indexPath: IndexPath)
    func disableTableView()
}

class FollowingNotificationCell: UITableViewCell {
    
    @IBOutlet weak var profilepicImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var commentImageView: UIImageView!
    
    weak var delegate:FollowingNotificationCellDelegate?
    var indexPath :IndexPath?
    var noti:ABNotification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButton.layer.cornerRadius = 3.0
        profilepicImageView.layer.masksToBounds = true
        profilepicImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profilepicImageView.layer.borderWidth = 2.0
        profilepicImageView.layer.cornerRadius = profilepicImageView.frame.size.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func profileButtonClick(_ sender: AnyObject) {
        if let delegateObject = delegate {
            delegateObject.profileButtonTapped(indexPath!)
        }
    }
    
    @IBAction func FollowButtonClick(_ sender: AnyObject) {
        followButton.setTitle("FOLLOWING", for: UIControlState())
        self.perform(#selector(FollowingNotificationCell.setProgress), with: nil, afterDelay: 2)
        if let delegateObject = delegate {
            delegateObject.disableTableView()
        }
    }
    
    func setProgress() {
        followButton.setTitle("+ FOLLOW", for: UIControlState())
        HeyParse.sharedInstance.followUser((noti?.fromUser)!, completionHandler: { (success) -> Void in
            if success {
                print("Follow req sent")
            }
        })
        
        if noti!.type == .followed || noti!.type == .requested {
            let noticatio = PFObject(withoutDataWithClassName: "Notification", objectId: noti!.objectId)
            noticatio.deleteInBackground()
        }
        
        if let delegateObject = delegate {
            delegateObject.followButtonClicked(indexPath!)
        }
        
    }
}
