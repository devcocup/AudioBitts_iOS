//
//  SearchFeedTVCell.swift
//  AudioBitts
//
//  Created by Phani on 2/4/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

//protocol SearchFeedTVCellDelegate: class {
//    func playButtonClick(_ indexPath: IndexPath)
//}
class SearchFeedTVCell: UITableViewCell {
    
    @IBOutlet weak var proflePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
   // @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var playCountLable: UILabel!
    @IBOutlet weak var playButton: UIButton!
    var indexpath: IndexPath!
    let searchVC = SearchVC()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        // Initialization code
//        proflePicImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).CGColor
//        proflePicImageView.layer.borderWidth = 2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func playButtonClick(_ sender: UIButton) {
    

    }
}
