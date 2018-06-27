//
//  FollowingRequestTVCell.swift
//  AudioBitts
//
//  Created by Navya on 03/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import SDWebImage


protocol FollowingRequestTVCellDelegate: class {
    func didActOnRequest(_ indexPath: IndexPath, tag: Int)
}

class FollowingRequestTVCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userActionsView: UIView!
    
    weak var delegate: FollowingRequestTVCellDelegate?
    var indexPath: IndexPath!
    var sourceClass: UIViewController!
    
    var user: ABUser! {
        didSet {
            updateTheUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicImageView.layer.masksToBounds = true
        profilePicImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profilePicImageView.layer.borderWidth = 2.0
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width/2
    }
    
    @IBAction func profileBtnAction(_ sender: UIButton) {
        let profileVCInstance = sourceClass.storyboard?.instantiateViewController(withIdentifier: "ProfileVC_ID") as! ProfileVC
        profileVCInstance.profileNavigationSource = ProfileVCNavigationSource.requestsVC
        profileVCInstance.isFollow = true
        profileVCInstance.userInformation = user
        sourceClass.navigationController?.pushViewController(profileVCInstance, animated: true)
    }
    
    func updateTheUI() {
        // Profile Image
        if let url = user.profilePic?.url {
            profilePicImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "profile_placeholder"))
        } else {
            setTextOnImageView(imageView: profilePicImageView, user: user, fromSideMenu: false)
        }
        
        userNameLabel.text = user.bitUserName?.chopPrefix()
        fullNameLabel.text = user.fullName
    }
    
    @IBAction func acceptOrRejectBtnAction(_ sender: UIButton) {
        if isInternetAvailable(true) {
            if sender.tag == 1 { // Accept
                // Accepting user
                HeyParse.sharedInstance.aceeptUserReq(user, completionHandler: { (sucess, isfollowing) -> Void in
                    if sucess {
                        print("sucess")
                    }
                })
                user.fullName = "Request accepted"
            } else { // Reject
                // Rejecting user
                HeyParse.sharedInstance.rejectUser(user, completionHandler: { (errorInformation) -> Void in
                    if let errorInformation = errorInformation {
                        print("Error in acceptOrRejectBtnAction in FollowingRequestTVCell: \(errorInformation)")
                    }
                })
                user.fullName = "Request rejected"
            }
            
            // UI updation
            userActionsView.isHidden = true
            fullNameLabel.text = user.fullName
            
            if let delegateObject = delegate {
                delegateObject.didActOnRequest(indexPath!, tag: sender.tag)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
