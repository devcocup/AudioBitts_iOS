//
//  ABFollowButton.swift
//  AudioBitts
//
//  Created by Ashok on 15/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

enum ABFollowButtonSource {
    case profile, notificationTVCell, followTVCell
}

protocol ABFollowButtonDelegate: class {
    func didChangeType(_ type: PersonRelationType)
}

extension ABFollowButtonDelegate {
    func didChangeType(_ type: PersonRelationType) {}
}

class ABFollowButton: UIButton {
    
    var type = PersonRelationType.follow {
        didSet {
            if let delegate = delegate {
                delegate.didChangeType(type)
            }
        }
    }
    
    var source = ABFollowButtonSource.profile
    var delegate: ABFollowButtonDelegate?
    
    //    required init(coder aDecoder: NSCoder) {
    //        super.init(coder: aDecoder)!
    //
    //        self.addTarget(self, action: "followBtnAction:", forControlEvents: UIControlEvents.TouchUpInside)
    //    }
    
    func configure(_ type: PersonRelationType, source: ABFollowButtonSource) {
        self.type = type
        self.source = source
        updateUI()
    }
    
    fileprivate func followBtnAction(_ sender: UIButton) {
        print("followBtnAction..")
    }
    
    fileprivate func updateUI() {
        
    }
    
}

private extension ABFollowButton {
    
    func updateFollowButton() {
        switch type {
        case .follow:
            setFollowButton(RGB(14, 25, 42), textColor: RGB(230, 31, 87), text: "+ FOLLOW")
        case .following:
            setFollowButton(RGB(230, 31, 87), textColor: RGB(255), text: "FOLLOWING")
        case .requested:
            setFollowButton(RGB(218), textColor: RGB(14, 25, 42), text: "REQUESTED")
        case .unblock, .currentUser:
            isEnabled = false
            alpha = 0.3
        }
    }
    
    func setFollowButton(_ bgColor: UIColor, textColor: UIColor, text: String) {
        backgroundColor = bgColor
        setTitle(text, for: UIControlState())
        setTitleColor(textColor, for: UIControlState())
    }
    
}
