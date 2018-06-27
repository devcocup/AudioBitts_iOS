//
//  VKAction.swift
//  VKActionSheet
//
//  Created by Vamsi on 23/12/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import UIKit

class VKAction : NSObject{
    
    var title : String?
    var image : UIImage?
    var bgcolor : UIColor?
    var cancelTitle: String?
    var handler: ((VKAction) -> Void)?
    
    init(title: String?, image: UIImage?, color: UIColor?, cancelTitle: String?, handler: ((VKAction?) -> Void)? = nil) {
        self.title = title
        self.image = image
        self.bgcolor = color
        self.cancelTitle = cancelTitle
        self.handler = handler
        super.init()
    }
}
