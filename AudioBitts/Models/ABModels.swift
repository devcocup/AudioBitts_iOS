//
//  ABModels.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import Foundation
import Parse

class ABMenuItem {
    let title : String
    let iconName : String
    let storyBoardID : String
    
    init(title: String, iconName: String, storyBoardID: String) {
        self.title = title
        self.iconName = iconName
        self.storyBoardID = storyBoardID
    }
}

//MARK: - Feed model
class ABFeed {
    var objectId: String?
    var bitTitle: String?
    var bitDescription: String?
    var bitImage: PFFile?
    var bitAudio: PFFile?
    var bitDuration: String?
    
    var postedBy: ABUser?
    var plays: Int?
    var comments: Int?
    var likes: Int?
    var createdAt: Date?
    var updatedAt: Date?
    
    //---> Others
    // From server
    var bittInteractionFlag = true
    var userInteractionFlag = true
    
    // Internal
    var isLikedByMe:Bool = false
    
    //parse object Mapping
    init(pfObject : PFObject) {
        self.objectId = pfObject.objectId
        self.bitTitle = pfObject["bitTitle"] as? String
        self.bitDescription = pfObject["description"] as? String
        self.bitImage = pfObject["bitImage"] as? PFFile
        self.bitAudio = pfObject["bitAudio"] as? PFFile
        self.bitDuration = pfObject["bitDuration"] as? String
        if let user = pfObject["postedBy"] as? PFUser{
            self.postedBy = ABUser(pfUser: user)
        }
        self.plays = pfObject["plays"] as? Int ?? 0
        self.comments = pfObject["comments"] as? Int ?? 0
        self.likes = pfObject["likes"] as? Int ?? 0
        self.createdAt = pfObject.createdAt
        self.updatedAt = pfObject.updatedAt
        
        //---> Others
        // From server
        //        bittInteractionFlag = pfObject["bittInteractionFlag"] as? Bool ?? true
        //        userInteractionFlag = pfObject["userInteractionFlag"] as? Bool ?? true
    }
    
    convenience init(pfObject:PFObject, isLikedByMe: Bool, bittInteractionFlag: Bool?, userInteractionFlag: Bool?) {
        self.init(pfObject:pfObject)
        self.isLikedByMe = isLikedByMe
        self.bittInteractionFlag = bittInteractionFlag ?? true
        self.userInteractionFlag = userInteractionFlag ?? true
    }
}

//MARK: - Comment model

class ABComment {
    var objectId: String?
    var bit: PFObject?
    var postedBy: ABUser?
    var comment: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    //parse object Mapping
    init(pfObject : PFObject) {
        self.objectId = pfObject.objectId
        self.bit = pfObject["bitId"] as? PFObject
        self.postedBy = ABUser(pfUser: (pfObject["commentBy"] as? PFUser)!)
        self.comment = pfObject["comment"] as? String
        self.createdAt = pfObject.createdAt
        self.updatedAt = pfObject.updatedAt
        
    }
}

//MARK: - Notification model

class ABNotification {
    var objectId: String?
    var bit: ABFeed?
    var fromUser: ABUser?
    var toUser: ABUser?
    var type: NotificationType?
    var isFollow: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    var isRead: Bool?
    var hasValidData = true
    
    //parse object Mapping
    init(pfObject : PFObject) {
        objectId = pfObject.objectId
        isFollow = pfObject["isFollowing"] as? Bool
        
        if let nType = pfObject["type"] as? String {
            switch nType {
            case "Comment":
                type = NotificationType.comment
            case "Like":
                type = NotificationType.like
            case "Follow":
                type = isFollow == true ? NotificationType.followed : NotificationType.requested
            default:
                type = nil
            }
        }
        
        if type != .followed && type != .requested {
            if let bittObject = pfObject["bitId"] as? PFObject {
                self.bit = ABFeed(pfObject: bittObject)
            }
        }
        
        if let user = pfObject["fromUser"] as? PFUser {
            fromUser = ABUser(pfUser: user)
        } else {
            print("'fromUser' not found: ObjectId: \(pfObject.objectId)")
            hasValidData = false
        }
        
        if let user = pfObject["toUser"] as? PFUser {
            toUser = ABUser(pfUser: user)
        } else {
            print("'toUser' not found: ObjectId: \(pfObject.objectId)")
            hasValidData = false
        }
        
        isRead = pfObject["isRead"] as? Bool
        createdAt = pfObject.createdAt
        updatedAt = pfObject.updatedAt
    }
}

//MARK: - Follow model

class ABFollow {
    var objectId: String?
    var user: PFUser?
    var followedBy: PFUser?
    
    //parse object Mapping
    init(pfObject : PFObject) {
        self.objectId = pfObject.objectId
        self.user = pfObject["user"] as? PFUser
        self.followedBy = pfObject["followedBy"] as? PFUser
    }
}

//MARK: - User model

class ABUser {
    
    var objectId: String?
    var userName: String?
    var fullName: String?
    var bitUserName: String?
    var profilePic: PFFile?
    var age: String?
    var email: String?
    var gender: String?
    var facebookId: String?
    var twitterId: String?
    var googleId: String?
    var emailVerified: Bool!
    var isPrivate:Bool!
    var isNotifyLikes:Bool!
    var isNotifyComments:Bool!
    var isNotifyNewFollowers:Bool!
    var isNotifyTags:Bool!
    var users_Blocked: [ABUser]?
    var users_BlockdBy: [ABUser]?
    var createdAt: Date?
    var updatedAt: Date?
    
    // user defined
    var isfollowing: Bool!
    var relationWithCurrentUser: PersonRelationType = .follow
    var isReqAccept: Bool?
    var numberOfFollowers :Int = 0
    
    //parse object Mapping
    
    let id: Int = 0
    
    init(pfUser: PFUser, basicInfoFlag: Bool? = nil) {
        self.objectId = pfUser.objectId
        self.createdAt = pfUser.createdAt
        self.updatedAt = pfUser.updatedAt
        
        if basicInfoFlag == true { return }
        
        self.userName = pfUser.username
        self.fullName = pfUser["fullName"] as? String
        self.bitUserName = pfUser["bitUsername"] as? String
        self.profilePic = pfUser["profilePic"] as? PFFile
        self.age = pfUser["age"] as? String
        self.email = pfUser.email
        self.gender = pfUser["gender"] as? String
        self.facebookId = pfUser["facebookId"] as? String
        self.twitterId = pfUser["twitterId"] as? String
        self.googleId = pfUser["googleId"] as? String
        self.emailVerified = pfUser["emailVerified"] as? Bool
        self.isPrivate = pfUser["isPrivate"] as? Bool ?? true
        self.isNotifyLikes = pfUser["notifyLikes"] as? Bool ?? true
        self.isNotifyComments = pfUser["notifyComments"] as? Bool ?? true
        self.isNotifyNewFollowers = pfUser["notifyFollowers"] as? Bool ?? true
        self.isNotifyTags = pfUser["notifyTags"] as? Bool ?? true
        
        // Blocked users
        if let blockedUsrs = pfUser["blocked"] as? [PFUser] {
            users_Blocked = [ABUser]()
            for item in blockedUsrs {
                users_Blocked!.append(ABUser(pfUser: item, basicInfoFlag: true))
            }
        }
        
        if let blockedUsrs = pfUser["blockedBy"] as? [PFUser] {
            users_BlockdBy = [ABUser]()
            for item in blockedUsrs {
                users_BlockdBy!.append(ABUser(pfUser: item, basicInfoFlag: true))
            }
        }
        //
    }
    
    convenience init(pfUser:PFUser, isfollowing:Bool) {
        self.init(pfUser:pfUser)
        self.isfollowing = isfollowing
    }
    
}

extension ABUser: Hashable {
    
    var hashValue: Int {
        return id
    }
    
}

