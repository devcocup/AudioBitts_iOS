//
//  FeedsTVCell.swift
//  AudioBitts
//
//  Created by Vamsi on 21/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import ActiveLabel

protocol FeedsCellDelegate: class {
    func likeButtonClicked(_ indexPath: IndexPath)
    func commentButtonClicked(_ indexPath: IndexPath)
    func shareButtonClicked(_ indexPath: IndexPath)
    func playButtonClicked(_ indexPath: IndexPath)
    func profilePicButtonClicked(_ IndexPath: IndexPath)
    func searchHashtags(string: String)
    
}

class FeedsTVCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tittlelabel: UILabel!
    @IBOutlet weak var bitImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var PlayCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    
    
    // Profile
    @IBOutlet weak var profileHeaderView: UIView!
    
    // Comment
    @IBOutlet weak var commentImgView: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    // Like
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // Share
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareImgView: UIImageView!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    weak var delegate: FeedsCellDelegate?
    var indexpath : IndexPath!
    //var hashtagHandler:((_ hashtag: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profileImageView.layer.borderWidth = 2.0
        print("awakeFromNib FeedsCellDelegate")
        
        descriptionLabel.handleMentionTap { (mention) in            
            print("\(mention) Tapped" )
            //send the string back to Explore
            self.mentionTapped(mention: mention)
            //self.hashtagHandler?(mention)
            

        }
        descriptionLabel.handleHashtagTap { (hashtag) in
            print("\(hashtag) Tapped" )
            //send the string back to Explore
            self.hashtagTapped(hashtag: hashtag)
            //self.hashtagHandler?(hashtag)
        }
        descriptionLabel.handleURLTap { (URL) in
            print("\(URL) Tapped" )
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Profile
    @IBAction func showFollowVC(_ sender: UIButton) {
        if let delegateObject = delegate {
            delegateObject.profilePicButtonClicked(indexpath)
        }
    }
    
    // Play
    @IBAction func playButtonAction(_ sender: UIButton) {
        if let delegateObject = delegate {
            delegateObject.playButtonClicked(indexpath)
        }
    }
    
    // Comment
    @IBAction func commentButtonAction(_ sender: UIButton) {
        if let delegateObject = delegate {
            delegateObject.commentButtonClicked(indexpath)
        }
    }
    
    // Like
    @IBAction func likeButtonAction(_ sender: UIButton) {
        if let delegateObject = delegate {
            delegateObject.likeButtonClicked(indexpath)
        }
    }
    
    // Share
    @IBAction func shareButtonAction(_ sender: UIButton) {
        if let delegateObject = delegate {
            delegateObject.shareButtonClicked(indexpath)
        }
    }
    
    func hashtagTapped(hashtag: String){
        if let delegateObject = delegate {
            delegateObject.searchHashtags(string: hashtag)
        }
    }
    
    func mentionTapped(mention: String){
        if let delegateObject = delegate {
            delegateObject.searchHashtags(string: mention)
        }
    }
    
}

