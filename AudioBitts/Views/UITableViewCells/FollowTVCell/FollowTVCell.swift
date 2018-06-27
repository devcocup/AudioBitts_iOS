//
//  FollowTableViewCell.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 25/01/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse
import SDWebImage

class FollowTVCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var saparatorLine: UIImageView!
    @IBOutlet weak var profileImageWidthConstraint: NSLayoutConstraint!
    var userInfo: ABUser! {
        didSet {
            updateTheUI()
        }
    }
    
    fileprivate var relationWithCurrentUser: PersonRelationType = .follow {
        didSet {
            userInfo.relationWithCurrentUser = relationWithCurrentUser
            updateFollowButton()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    fileprivate func updateTheUI() {
        profileImageView.sd_setImage(with: URL(string: userInfo.profilePic?.url ?? "" ), placeholderImage: UIImage(named: "profile_placeholder"))
        userNameLabel.text = userInfo.bitUserName?.chopPrefix()
        nameLabel.text = userInfo.fullName
        relationWithCurrentUser = userInfo.relationWithCurrentUser
    }
    
    fileprivate func updateFollowButton() {
        switch relationWithCurrentUser {
        case .follow:
            setFollowButton(RGB(14, 25, 42), textColor: RGB(230, 31, 87), text: "+ FOLLOW")
        case .following:
            setFollowButton(RGB(230, 31, 87), textColor: RGB(255), text: "FOLLOWING")
        case .requested:
            setFollowButton(RGB(218), textColor: RGB(14, 25, 42), text: "REQUESTED")
        case .unblock, .currentUser:
            followButton.isEnabled = false
            followButton.alpha = 0.3
        }
    }
    
    fileprivate func setFollowButton(_ bgColor: UIColor, textColor: UIColor, text: String) {
        followButton.backgroundColor = bgColor
        
        followButton.setTitle(text, for: UIControlState())
        followButton.setTitleColor(textColor, for: UIControlState())
    }
    
    func matchToSearchUI(_ followerCount:Int){
        userNameLabel.textColor = UIColor.black
        profileImageView.layer.cornerRadius = 20
        nameLabel.textColor = UIColor(red: 129 , green:129 , blue: 129)
        profileImageWidthConstraint.constant = 40
        profileImageView.layer.borderWidth = 2
        if followerCount == 0 {
            nameLabel.text = "No follower"
        }else if followerCount == 1 {
            nameLabel.text = "\(followerCount) follower"
        }else{
            nameLabel.text = "\(followerCount) followers"
        }
        
        self.layoutIfNeeded()
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
                    print("Success: followUser in FollowTVCell")
                    // sending push for feed user
                    HeyParse.sharedInstance.followPush(self.userInfo)
                }
            })
            
        case .following:
            print("Following")
            relationWithCurrentUser = .follow
            HeyParse.sharedInstance.unFollowUser(userInfo, completionHandler: { (success) -> Void in
                if success {
                    print("Success: unFollowUser in FollowTVCell")
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
    }
    
    
}
