//
//  CommentNotificationTVCell.swift
//  AudioBitts
//
//  Created by Navya on 03/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

protocol CommentNotificationTVCellDelegate: class {
    func commentProfileButtonTapped(_ indexPath: IndexPath)
}

class CommentNotificationTVCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var bitImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    
    var indexPath :IndexPath?
    var noti:ABNotification?
    weak var delegate:CommentNotificationTVCellDelegate?
    
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
    @IBAction func profileButtonAction(_ sender: AnyObject) {
        if let delegateObject = delegate {
            delegateObject.commentProfileButtonTapped(indexPath!)
        }
    }
}
