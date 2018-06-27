//
//  VKActionCell.swift
//  VKActionSheet
//
//  Created by Vamsi on 23/12/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import UIKit

class VKActionCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
