//
//  CommentTVCell.swift
//  AudioBitts
//
//  Created by Phani on 12/28/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentTVCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var bottomLineView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commentLabel.handleMentionTap {
            userHandle in print("\(userHandle) tapped")
            
        }
        commentLabel.handleHashtagTap {
            hashtag in print("\(hashtag) tapped")
            
        }
        commentLabel.handleURLTap {
            url in print("\(url) tapped")
            
        }
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profileImageView.layer.borderWidth = 2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
