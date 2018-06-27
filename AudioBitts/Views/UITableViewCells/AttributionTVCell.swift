//
//  AttributionTVCell.swift
//  AudioBitts
//
//  Created by Navya on 05/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class AttributionTVCell: UITableViewCell {

    @IBOutlet weak var contentOfLibraryLabel: UILabel!
    @IBOutlet weak var libraryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
