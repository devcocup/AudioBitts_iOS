//
//  AudioPlayerInterfaceVC.swift
//  AudioBitts
//
//  Created by Ashok on 12/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

protocol ProfileHeaderVCDelegate: class {
    func myBitsButtonClicked()
    func bitsOfMeButtonClicked()
}

class ProfileHeaderVC: UIViewController {
    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var firstSegmentButton: UIButton!
    @IBOutlet weak var firstSegmentBottomLine: UIView!
    @IBOutlet weak var secondSegmentButton: UIButton!
    @IBOutlet weak var secondSegmentBottomLine: UIView!
    @IBOutlet weak var segmentViewHeight: NSLayoutConstraint!
    
    weak var delegate: ProfileHeaderVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        secondSegmentBottomLine.isHidden = true
        firstSegmentButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        secondSegmentButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isShowingMyBits(_ isMybiits:Bool) {
        if isMybiits {
            secondSegmentBottomLine.isHidden = true
            firstSegmentBottomLine.isHidden = false
            firstSegmentButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
            secondSegmentButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
        } else {
            firstSegmentBottomLine.isHidden = true
            secondSegmentBottomLine.isHidden = false
            firstSegmentButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
            secondSegmentButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        }
    }
    
    @IBAction func firstSegmentBtnAction(_ sender: UIButton) {
        secondSegmentBottomLine.isHidden = true
        firstSegmentBottomLine.isHidden = false
        firstSegmentButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        secondSegmentButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
        if let delegateObject = delegate {
            delegateObject.myBitsButtonClicked()
        }
    }
    
    @IBAction func secondSegmentBtnAction(_ sender: UIButton) {
        secondSegmentBottomLine.isHidden = false
        firstSegmentBottomLine.isHidden = true
        firstSegmentButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
        secondSegmentButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        if let delegateObject = delegate {
            delegateObject.bitsOfMeButtonClicked()
        }
    }
    
}
