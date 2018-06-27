//
//  SerachSectionTVCell.swift
//  AudioBitts
//
//  Created by Phani on 4/21/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class SerachSectionTVCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var sectionTittle: UILabel!
}
