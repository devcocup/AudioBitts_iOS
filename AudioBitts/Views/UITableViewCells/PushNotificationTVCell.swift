//
//  PushNotificationTVCell.swift
//  AudioBitts
//
//  Created by Phani on 2/1/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse

enum PushNootificationType: String {
    case Likes = "notifyLikes"
    case Comments = "notifyComments"
    case Followers = "notifyFollowers"
    case Tags = "notifyTags"
}

class PushNotificationTVCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    var notificationType: PushNootificationType!
    var indexPath :IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func switchChange(_ sender: UISwitch) {
        if nameLabel.text == "Likes" {
            //self.trackEvent(GASNPushNotificationsSetting, action: GAEVNotificationLikes, label: "", value: nil)
            enableNotifications(PushNootificationType.Likes.rawValue, switchState: sender.isOn)
        } else if (nameLabel.text == "Comments") {
            //self.trackEvent(GASNPushNotificationsSetting, action: GAEVNotificationComments, label: "", value: nil)
            enableNotifications(PushNootificationType.Comments.rawValue, switchState: sender.isOn)
        } else if (nameLabel.text == "New Followers") {
            //self.trackEvent(GASNPushNotificationsSetting, action: GAEVNotificationNewFollower, label: "", value: nil)
            enableNotifications(PushNootificationType.Followers.rawValue, switchState: sender.isOn)
        } else {
            //self.trackEvent(GASNPushNotificationsSetting, action: GAEVNotificationTags, label: "", value: nil)
            enableNotifications(PushNootificationType.Tags.rawValue, switchState: sender.isOn)
        }
    }
    func enableNotifications(_ typeOfnotification : String, switchState : Bool) {
        let user = PFUser.current()!
        if switchState == true {
            user[typeOfnotification] = true
        } else {
            user[typeOfnotification] = false
        }
        user.saveInBackground { (isSucess, error) -> Void in
            if isSucess {
                print("Success Block")
            } else {
                print("Failure Block")
            }
        }
    }
}
