//
//  SettingsTVCell.swift
//  AudioBitts
//
//  Created by Navya on 01/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class SettingsTVCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
