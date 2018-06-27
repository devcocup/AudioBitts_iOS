//
//  MenuTVCell.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

class MenuTVCell: UITableViewCell {
    
    @IBOutlet weak var iconimageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
