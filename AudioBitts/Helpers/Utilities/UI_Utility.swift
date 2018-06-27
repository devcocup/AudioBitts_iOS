//
//  UI_Utility.swift
//  AudioBitts
//
//  Created by Ashok on 13/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation

extension UILabel {
    func updateWidthAsPerNotificationCount() {
        var calculatedWidth = self.text!.sizeOfStringwithHight(UIFont.museoSans700FontOfSize(10), constrainedToHeight: 20).width + 10.0
        if calculatedWidth < 21 { calculatedWidth = 21 }
        self.frame.size.width = calculatedWidth
    }
}
