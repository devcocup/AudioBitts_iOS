 //
 //  SelectionCVCell.swift
 //  CamPlusAudio
 //
 //  Created by Ashok on 10/12/15.
 //  Copyright © 2015 Ashok. All rights reserved.
 //
 
 import UIKit
 
 class SelectionCVCell: UICollectionViewCell {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bitImageView: UIImageView!
    @IBOutlet fileprivate weak var selectedImageView: UIImageView!
    
    var isPicSelected: Bool = false {
        didSet {
            if isPicSelected {
                selectedImageView.image = UIImage(named: "accept")
                countLabel.isHidden = true
            } else {
                countLabel.isHidden = false
                selectedImageView.image = nil
            }
        }
    }
 }
