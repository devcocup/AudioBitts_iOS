//
//  NotificationTVCell.swift
//  AudioBitts
//
//  Created by Ashok on 12/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse
import SDWebImage

protocol NotificationTVCellDelegate: class {
    func didTapOnProfilePic(_ inCell: NotificationTVCell, indexPath: IndexPath)
    func didTapOnFollowButton(_ inCell: NotificationTVCell, indexPath: IndexPath)
}

class NotificationTVCell: UITableViewCell {
    
    // General
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationTypeImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    
    // Comment or Like
    @IBOutlet weak var bittImageView: UIImageView!
    
    // Followed
    @IBOutlet weak var followButton: UIButton!
    fileprivate var relationWithCurrentUser: PersonRelationType = .follow {
        didSet {
            userInfo.relationWithCurrentUser = relationWithCurrentUser
            updateFollowButton()
        }
    }
    //
    
    // Requested
    @IBOutlet weak var forwardArrowImageView: UIImageView!
    
    weak var delegate: NotificationTVCellDelegate?
    var indexPath: IndexPath!
    
    var notificationInfo: ABNotification? {
        didSet {
            userInfo = notificationInfo?.fromUser
            updateDeatails()
        }
    }
    
    var userInfo: ABUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateDeatails() {
        // Generic
        let notificationTitleText = NSMutableAttributedString()
        notificationTitleText.append(NSAttributedString(string: userInfo?.bitUserName?.chopPrefix() ?? "",
            attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.museoSans500FontOfSize(14)]))
        var titleString = ""
        
        var typeImage: UIImage!
        
        func arrangeTheTypes() {
            switch notificationInfo!.type! {
            case .comment, .like:
                typeImage = UIImage(named: "\(notificationInfo!.type! == .comment ? "notification_smallComment" : "notification_smallLike")")
                titleString = notificationInfo!.type! == .comment ? " commented" : " liked your bitt"
                
                /*** UI Management ***/
                // Unhiding own elements
                bittImageView.isHidden = false
                
                // Hiding others
                followButton.isHidden = true
                forwardArrowImageView.isHidden = true
                
                if let bitt = notificationInfo!.bit {
                    bittImageView.sd_setImage(with: URL(string: bitt.bitImage?.url ?? "" ), placeholderImage: UIImage(named: "profile_placeholder"))
                } else {
                    bittImageView.isHidden = true
                }
                
            case .followed:
                typeImage = UIImage(named: "notification_addButton")
                titleString = " followed you"
                
                /*** UI Management ***/
                // Unhiding own elements
                followButton.isHidden = false
                
                // Hiding others
                bittImageView.isHidden = true
                forwardArrowImageView.isHidden = true
                
            case .requested:
                typeImage = UIImage(named: "notification_addButton")
                titleString = " Requested to follow you"
                
                /*** UI Management ***/
                // Unhiding own elements
                forwardArrowImageView.isHidden = false
                
                // Hiding others
                followButton.isHidden = true
                bittImageView.isHidden = true
                
            }
        }
        arrangeTheTypes()
        
        // Read or Unread status
        self.backgroundColor = notificationInfo?.isRead == true ? UIColor.white :  RGB(227, 236, 249, 1)
        
        // Profile Image
        if let url = userInfo.profilePic?.url {
            profileImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "profile_placeholder"))
        } else {
            setTextOnImageView(imageView: profileImageView, user: userInfo, fromSideMenu: false)
        }
        
        // Title
        notificationTitleText.append(NSAttributedString(string: titleString,
            attributes: [NSForegroundColorAttributeName: UIColor.abDarkLightGrayColor(), NSFontAttributeName: UIFont.museoSans300FontOfSize(14)]))
        notificationTitleLabel.attributedText = notificationTitleText
        
        // Notification Type Image
        notificationTypeImageView.image = typeImage
        
        // Duration
        durationLabel.text = notificationInfo!.createdAt?.timeAgo
        
        // Others
        relationWithCurrentUser = userInfo.relationWithCurrentUser
    }
    
    fileprivate func updateFollowButton() {
        switch relationWithCurrentUser {
        case .follow:
            setFollowButton(RGB(14, 25, 42), imageName: "follow")
        case .following:
            setFollowButton(RGB(230, 31, 87), imageName: "following")
        case .requested:
            setFollowButton(RGB(218), imageName: "requested")
        case .unblock, .currentUser:
            followButton.isEnabled = false
            followButton.alpha = 0.3
        }
    }
    
    fileprivate func setFollowButton(_ bgColor: UIColor, imageName: String) {
        followButton.backgroundColor = bgColor
        followButton.setImage(UIImage(named: imageName), for: UIControlState())
    }
    
    @IBAction func profileBtnAction(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.didTapOnProfilePic(self, indexPath: indexPath)
        }
    }
    
    @IBAction func followBtnAction(_ sender: UIButton) {
        switch relationWithCurrentUser {
        case .follow:
            print("Follow")
            if userInfo.objectId == PFUser.current()?.objectId {
                showAlertOnWindow(message: "You can't follow your own profile!")
                return;
            }
            relationWithCurrentUser = (userInfo.isPrivate)! ? .requested : .following
            HeyParse.sharedInstance.followUser(userInfo, completionHandler: { (success) -> Void in
                if success {
                    print("Success: followUser in NotificationTVCell")
                    // sending push for feed user
                    HeyParse.sharedInstance.followPush(self.userInfo)
                }
            })
            
        case .following:
            print("Following")
            relationWithCurrentUser = .follow
            HeyParse.sharedInstance.unFollowUser(userInfo, completionHandler: { (success) -> Void in
                if success {
                    print("Success: unFollowUser in NotificationTVCell")
                }
            })
            
        case .requested:
            print("Requested")
            print("Do nothing here for now.")
            
        case .unblock:
            print("Unblock")
            print("Do nothing here for now.")
            
        case .currentUser:
            print("CurrentUser")
            print("Do nothing here for now.")
        }
        
        if let delegate = self.delegate {
            delegate.didTapOnFollowButton(self, indexPath: indexPath)
        }
    }
    
}
