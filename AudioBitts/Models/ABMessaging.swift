//
//  ABMessaging.swift
//  AudioBitts
//
//  Created by Denzil Dsa on 6/7/18.
//  Copyright © 2018 mobileways. All rights reserved.
//

import Foundation
import Parse


class ABMessaging: PFObject {
    var postedBy: ABUser?
    var postedTo: [ABUser]?
    var message: [ABMessage]?
    var messageBit: [ABMessageBit]?
    
    init(from: ABUser, to: [ABUser], msg: [ABMessage]) {
        super.init()
        postedBy = from
        postedTo = to
        message = msg
    }
}

class ABMessage {
    var postedBy: ABUser?
    var text: String?

}

class ABMessageBit: ABFeed {

    
}
