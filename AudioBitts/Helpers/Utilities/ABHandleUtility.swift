//
//  ABHandleUtility.swift
//  AudioBitts
//
//  Created by Denzil Dsa on 5/31/18.
//  Copyright © 2018 mobileways. All rights reserved.
//

import Foundation
import ActiveLabel

var userFeedActiveLabel: ActiveLabel?


func mentionLabelTapHandler(description: String){
    
    userFeedActiveLabel?.handleMentionTap( { (mention) -> Void in
        
    })
}

func hashtagTapHandler(hashtag: String){
    
    userFeedActiveLabel?.handleMentionTap( { (hashtag) -> Void in
    
    })
}

func urlTapHandler(url: String){
    
    userFeedActiveLabel?.handleMentionTap( { (url) -> Void in
        
    })
}
