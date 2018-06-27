//
//  HeyParse.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 22/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class HeyParse: NSObject {
    
    static let sharedInstance = HeyParse()
    
    // MARK:- ---> PFConfig
    
    func getAppConfiguration() {
        PFConfig.getInBackground {
            (config, error) in
            
            if let errorReportMail = config?["errorReportMail"] as? String {
                SharedManager.sharedInstance.errorReportMail = errorReportMail
            }
            
            if let feedbackEmail = config?["feedbackMail"] as? String {
                SharedManager.sharedInstance.feedbackEmail = feedbackEmail
            }
            
            if let reportAbuseMail = config?["reportAbuseMail"] as? String {
                SharedManager.sharedInstance.reportAbuseMail = reportAbuseMail
            }
            
            if let attbrText = config?["attributionText"] as? String {
                SharedManager.sharedInstance.attributionText = attbrText
            }
            
            if let termsAndConditions = config?["privacyPolicy"] as? PFFile {
                termsAndConditions.getDataInBackground(block: { (data, error) -> Void in
                    guard let data = data else {
                        if let error = error { print(error)}
                        return;}
                    SharedManager.sharedInstance.privacyPolicy = String(data: data, encoding: String.Encoding.utf8)!
                })
            }
            
            if let termsAndConditions = config?["termsAndConditions"] as? PFFile {
                termsAndConditions.getDataInBackground(block: { (data, error) -> Void in
                    guard let data = data else {
                        if let error = error { print(error)}
                        return;}
                    SharedManager.sharedInstance.termsAndConditions = String(data: data, encoding: String.Encoding.utf8)!
                })
            }
        }
    }
    
    // MARK: PFConfig <---
    
    //MARK: User login -------->
    
    func forgotpassword(_ username:String , completionHandler : @escaping (_ isSucceeded: Bool, _ message: String) -> Void) ->Void {
        
        if isInternetAvailable(true) {
            let query = PFUser.query()
            query?.whereKey("username", equalTo:username)
            query?.findObjectsInBackground {
                (objects, error) -> Void in
                
                if error == nil {
                    if objects!.count > 0 {
                        PFUser.requestPasswordResetForEmail(inBackground: username)
                        completionHandler (true, "Reset link send to your email")
                    } else {
                        completionHandler (false, "User not exists")
                        
                    }
                } else {
                    // Log details of the failure
                    completionHandler (false, "Error: \(error!) \(error!._userInfo)")
                    print("Error: \(error!) \(error!._userInfo)")
                }
            }
        } else {
            completionHandler (false, VLInternetErrorString)
        }
    }
    
    func signUpForNewUser(_ currentuser: User , completionHandler : @escaping (_ isSucceeded: Bool, _ errorInformation:String?) -> Void) -> Void {
        // check is internet available
        if isInternetAvailable(true) {
            let user = PFUser()
            user.username = currentuser.username
            user.password = currentuser.pwd
            user.email = currentuser.email
            // other fields can be set just like with PFObject
            user["fullName"] = currentuser.name
            if let id = currentuser.googleId {
                user["googleId"] = id
            }
            
            user.signUpInBackground(block: { (succeeded, error) in
                if succeeded {
                    // register for notifications
                    let currentInstallation = PFInstallation.current()
                    currentInstallation?["user"] = user
                    currentInstallation?["bitUsername"] = user["bitUsername"] ?? ""
                    currentInstallation?.saveInBackground()
                    SharedManager.sharedInstance.foundUserSignUp()
                }
                completionHandler(succeeded, error?.localizedDescription)
            })
        } else {
            completionHandler(false, VLInternetErrorString)
            
        }
    }
    
    func loginUser(_ userName:String, password:String, completionHandler : @escaping (_ isSucceeded: Bool, _ errorInformation:String?) -> Void) -> Void {
        if isInternetAvailable(true) {
            PFUser.logInWithUsername(inBackground: userName, password: password, block: { (user, error) in
                if user != nil {
                    completionHandler(true, error?.localizedDescription)
                    if let userdata = user {
                        let currentInstallation = PFInstallation.current()
                        currentInstallation?["user"] = userdata
                        currentInstallation?["bitUsername"] = userdata["bitUsername"] ?? ""
                        currentInstallation?.saveInBackground()
                    }
                } else {
                    completionHandler(false, error?.localizedDescription)
                }
            })
        } else {
            completionHandler(false, VLInternetErrorString)
        }
    }
    
    //MARK: User login <--------
    
    func getMyFeeds(_ userID: String,profileID:String,pageNo: Int, completionHandler : @escaping ((_ success : Bool ,_ feeds : [ABFeed]) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "getBits", withParameters: ["userId": userID, "profileId": profileID, "pageNo": pageNo], block: { (response, error) in
                var feeds = [ABFeed]()
                if error != nil { // Error when fetching user with name
                    completionHandler(false , feeds)
                } else if let dataDir = response as? [[String: AnyObject]] {
                    if userID.characters.count > 2 {
                        //with userID global feeds liked by userID
                        for object in dataDir {
                            var isliked = false
                            if let likeStatus = object["likeStatus"] as? Int {
                                if (likeStatus == 1){ isliked = true }
                            }
                            if let feed = object["feed"] as? PFObject {
                                feeds.append(ABFeed(pfObject: feed, isLikedByMe: isliked, bittInteractionFlag: object["bittInteractionFlag"] as? Bool, userInteractionFlag: object["userInteractionFlag"] as? Bool))
                            }
                        }
                    } else {
                        for object in dataDir {
                            if let feed = object as? PFObject {
                                feeds.append(ABFeed(pfObject: feed))
                            }
                        }
                    }
                    completionHandler(true, feeds)
                } else {
                    completionHandler(false, feeds)
                }
            })
        }
    }
    
    func getMyFeedsCount(_ user: ABUser?, completionHandler : @escaping ((_ feedsCount : Int32) -> Void)) {
        if isInternetAvailable(true) {
            if  let userId = user?.objectId {
                let query = PFQuery(className:"Feeds")
                query.whereKey("postedBy", equalTo:PFUser(withoutDataWithClassName: "_User", objectId: userId))
                query.includeKey("postedBy")
                query.countObjectsInBackground(block: { (count, error) -> Void in
                    if error == nil {
                        completionHandler(count)
                    } else {
                        print("Error: \(error!)")
                        completionHandler(0)
                    }
                })
            }
        }
    }
    
    func updateFeed(_ feed: ABFeed?, completionHandler : @escaping ((_ feed : ABFeed) -> Void)) {
        if isInternetAvailable(true) {
            if  let feedId = feed?.objectId {
                let query = PFQuery(className:"Feeds")
                query.whereKey("objectId", equalTo:feedId)
                query.includeKey("postedBy")
                query.getFirstObjectInBackground(block: { (object, error) -> Void in
                    if error == nil {
                        // Converting PFObject to ABFeed Object
                        if let item = object {
                            completionHandler(ABFeed(pfObject: item))
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!)")
                    }
                })
            }
        }
    }
    
    // get bit comments
    func getBitComments(_ bit:ABFeed , completionHandler : @escaping ((_ comments : [ABComment]) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Comments")
            query.whereKey("bitId", equalTo: PFObject(withoutDataWithClassName: "Feeds", objectId: bit.objectId))
            query.includeKey("commentBy")
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    var commentsArray = [ABComment]()
                    if let objects = objects {
                        for object in objects {
                            commentsArray.append(ABComment(pfObject: object))
                        }
                        completionHandler(commentsArray)
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!._userInfo)")
                }
            })
        }
    }
    
    
    func getTrendingFeeds( _ completionHandler : @escaping (( _ sucess:Bool ,_ trendingFeeds : [ABFeed]) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Feeds")
            query.order(byDescending: "playCount")
            query.includeKey("postedBy")
            query.limit = 10
            query.findObjectsInBackground(block: { (objects, error) in
                var feedssArray = [ABFeed]()
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects {
                        for object in objects {
                            feedssArray.append(ABFeed(pfObject: object))
                        }
                        completionHandler(true,feedssArray)
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!._userInfo)")
                    completionHandler(false,feedssArray)
                }
            })
        }
    }
    
    // save bit comments using cloud function
    
    func addComment(_ comment:String, bitId:String , completionHandler : @escaping ((_ success : Bool ,_ comment:PFObject? ) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "addComment", withParameters: ["bitId": bitId, "commentBy": PFUser.current()?.objectId ?? "", "comment": comment], block: { (response, error) in
                if error != nil { // Error when fetching user with name
                    completionHandler(false , nil)
                } else if let comment = response as? PFObject{
                    print(comment)
                    completionHandler(true ,comment)
                } else {
                    completionHandler(false,nil)
                }
            })
        }
    }
    
    //Update likes count
    func updateLikeCount(_ bitId:String , isLiked:Bool,completionHandler : @escaping ((_ success : Bool ,_ feed:ABFeed?) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "updateLikesCount", withParameters: ["bitId": bitId , "likedBy": PFUser.current()?.objectId ?? "" , "isLiked" :isLiked], block: { (response, error) in
                if error != nil { // Error when fetching user with name
                    completionHandler(false ,nil)
                } else if let feed = response as? PFObject {
                    completionHandler(true, ABFeed(pfObject: feed))
                } else {
                    completionHandler(false,nil)
                }
            })
        }
    }
    
    //Update play  count
    func updatePlayCount(_ bitId:String, completionHandler : @escaping ((_ success : Bool,_ feed:ABFeed?) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "updatePlayCount", withParameters: ["bitId": bitId , "playedBy": PFUser.current()?.objectId ?? ""], block: { (reponse, error) in
                if error != nil { // Error when fetching user with name
                    completionHandler(false,nil)
                } else if let feed = reponse as? PFObject{
                    completionHandler(true ,ABFeed(pfObject: feed))
                } else {
                    completionHandler(false,nil)
                }
            })
        }
    }
    
    //        func getFollowerAndFollowingUsers(user:ABUser? , completionHandler : ((success : Bool,followers: [ABUser] ,following: [ABUser]) -> Void)) {
    //            if isInternetAvailable(true) {
    //                if let userid = user?.objectId {
    //                    PFCloud.callFunctionInBackground("getFolowedAndFollowers", withParameters: ["userId": userid]) {
    //                        (response: AnyObject?, error: Error?) -> Void in
    //                            var followersArray = [ABUser]()
    //                            var followerbyArray = [ABUser]()
    //
    //                        if error != nil { // Error when fetching user with name
    //                            completionHandler(success: false , followers:followersArray,following:followerbyArray )
    //                        } else if let data = response {
    //                            print(data)
    //                            if let followers = data["followers"] as? [PFObject] {
    //                                for object in followers {
    //                                    if let userObj = object["followedBy"] as? PFUser {
    //                                        followersArray.append(ABUser(pfUser: userObj))
    //                                    }
    //                                }
    //                            }
    //                            if let followerby = data["followedBy"] as? [PFObject]{
    //                                for object in followerby {
    //                                    if let userObj = object["user"] as? PFUser{
    //                                        followerbyArray.append(ABUser(pfUser: userObj))
    //                                    }
    //                                }
    //                            }
    //
    //                            completionHandler(success: true , followers:followersArray,following:followerbyArray )
    //                        } else {
    //                            completionHandler(success: false , followers:followersArray,following:followerbyArray )
    //                        }
    //                    }
    //                }
    //            }
    //        }
    
    func getFollowerAndFollowingUsers(_ userInformation: ABUser , completionHandler : @escaping ((_ followers: [ABUser]?, _ following: [ABUser]?, _ errorInfo: String?) -> Void)) {
        if isInternetAvailable(true) {
            
            var followersArray_NormalUser = [ABUser]()
            var followingArray_NormalUser = [ABUser]()
            var wholeFollowingArray_NormalUser = [ABUser]()
            
            let followersQuery = PFQuery(className:"Follow")
            followersQuery.whereKey("user", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: userInformation.objectId))
            
            let followingQuery = PFQuery(className:"Follow")
            followingQuery.whereKey("followedBy", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: userInformation.objectId))
            
            var queriesArray = [followersQuery, followingQuery]
            
            var wholeFollowingArray_CurrentUser = [ABUser]()
            //            let currentUserObjectID = ABUserManager.sharedInstance.currentUser!.objectId
            let currentUserObjectID = PFUser.current()!.objectId
            
            if userInformation.objectId != currentUserObjectID {
                let currentUserFollowingUsersQuery = PFQuery(className:"Follow")
                followingQuery.whereKey("followedBy", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: currentUserObjectID))
                queriesArray.append(currentUserFollowingUsersQuery)
            }
            
            let query = PFQuery.orQuery(withSubqueries: queriesArray)
            query.includeKey("user")
            query.includeKey("followedBy")
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    //                    print("objects: \(objects)")
                    print("______get Follower And Following Users:")
                    
                    if let objects = objects {
                        
                        /*** Objects' Iteration ***/
                        for item in objects {
                            if let user = item["user"] as? PFUser, let followedBy = item["followedBy"] as? PFUser {
                                print("user: \(user["bitUsername"]) --> followedBy: \(followedBy["bitUsername"]), isReqAccept: \(item["isReqAccept"] as!Bool)")
                                
                                if userInformation.objectId != currentUserObjectID {
                                    if followedBy.objectId == currentUserObjectID { // Current user's "Following"
                                        let mappedUser = ABUser(pfUser: user)
                                        mappedUser.isReqAccept = item["isReqAccept"] as! Bool ? true : false
                                        wholeFollowingArray_CurrentUser.append(mappedUser)
                                    }
                                }
                                
                                if user.objectId == userInformation.objectId { // Followers
                                    let mappedUser = ABUser(pfUser: followedBy)
                                    if item["isReqAccept"] as! Bool {
                                        followersArray_NormalUser.append(mappedUser)
                                    }
                                } else if followedBy.objectId == userInformation.objectId { // Following
                                    let mappedUser = ABUser(pfUser: user)
                                    mappedUser.isReqAccept = item["isReqAccept"] as! Bool ? true : false
                                    wholeFollowingArray_NormalUser.append(mappedUser)
                                    if item["isReqAccept"] as! Bool {
                                        followingArray_NormalUser.append(mappedUser)
                                    }
                                }
                            } else {
                                print("'user' or 'followedBy' column value is missing in 'Follow' table, ObjecId: \(item.objectId)")
                            }
                        }
                        // <--
                        
                        /*** Finding the realtions ***/
                        let wholeFollowingArray_ToConsider = userInformation.objectId != currentUserObjectID ? wholeFollowingArray_CurrentUser : wholeFollowingArray_NormalUser
                        // Finding current user's relation with each item in 'followersArray' array
                        self.findoutUsersRelationWithCurrentUser(wholeFollowingArray_ToConsider, listOfUser: &followersArray_NormalUser)
                        
                        // Finding current user's relation with each item in 'followingArray' array
                        self.findoutUsersRelationWithCurrentUser(wholeFollowingArray_ToConsider, listOfUser: &followingArray_NormalUser)
                        // <--
                        
                        completionHandler(followersArray_NormalUser, followingArray_NormalUser, nil)
                    }
                } else {
                    print("Error: \(error!) \(error!._userInfo)")
                    completionHandler(nil, nil, error!.localizedDescription)
                }
            })
        }
    }
    
    func findoutUsersRelationWithCurrentUser(_ wholeFollowingArray_Gerenric: [ABUser], listOfUser: inout [ABUser], shouldFilterUsers: Bool = true) {
        for user in listOfUser {
            if user.objectId == PFUser.current()?.objectId {
                user.relationWithCurrentUser = PersonRelationType.currentUser
                continue
            }
            for item in wholeFollowingArray_Gerenric {
                if user.bitUserName == item.bitUserName {
                    if item.isReqAccept! {
                        user.relationWithCurrentUser = PersonRelationType.following
                    } else {
                        user.relationWithCurrentUser = PersonRelationType.requested
                    }
                }
            }
        }
        
        if shouldFilterUsers { listOfUser = uniq(listOfUser) }
        print("\n_____listOfUser:")
        for item in listOfUser {
            print("\(item.bitUserName!) : \(item.relationWithCurrentUser)")
        }
    }
    
    func getCurrentUserFollowingListAndFindOutRelationWithUsers(_ usersFromNotification: [ABUser], completionHandler: @escaping (_ errorInfo: String?) -> Void) {
        //        getInformationFromFollowTable(forUser: ABUserManager.sharedInstance.currentUser!, followersFlag: false) { (objects, error) -> Void in
        var tmp = usersFromNotification
        getInformationFromFollowTable(forUser: ABUser(pfUser: PFUser.current()!), followersFlag: false) { (objects, error) -> Void in
            if error == nil {
                if let objects = objects {
                    var wholeFollowingArray_CurrentUser = [ABUser]()
                    
                    for item in objects {
                        let user = item["user"] as! PFUser
                        
                        let mappedUser = ABUser(pfUser: user)
                        mappedUser.isReqAccept = item["isReqAccept"] as! Bool ? true : false
                        wholeFollowingArray_CurrentUser.append(mappedUser)
                    }
                    
                    /*** Finding the realtions ***/
                    // Finding current user's relation with each item in 'followingArray' array
                    
                    self.findoutUsersRelationWithCurrentUser(wholeFollowingArray_CurrentUser, listOfUser: &tmp, shouldFilterUsers: false)
                    // <--
                    
                    completionHandler(nil)
                } else {
                    completionHandler("No data found!")
                }
            } else {
                print("Error: \(error!._userInfo)")
                completionHandler(error!.localizedDescription)
            }
        }
    }
    
    func getInformationFromFollowTable(forUser userInformation: ABUser, followersFlag: Bool? = true, followingFlag: Bool? = true, completionBlock: @escaping (_ objects: [PFObject]?, _ error: Error?) -> Void) {
        
        var subQueries = [PFQuery]()
        if followersFlag == true {
            let followersQuery = PFQuery(className:"Follow")
            followersQuery.whereKey("user", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: userInformation.objectId))
            
            subQueries.append(followersQuery)
        }
        
        if followingFlag == true {
            let followingQuery = PFQuery(className:"Follow")
            followingQuery.whereKey("followedBy", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: userInformation.objectId))
            
            subQueries.append(followingQuery)
        }
        
        let query = PFQuery.orQuery(withSubqueries: subQueries)
        query.includeKey("user")
        query.includeKey("followedBy")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            completionBlock(objects, error)
        }
    }
    
    func getFeedsForUser(_ userID:String , pageNo: Int ,isGlobalFeeds:Bool, completionHandler : @escaping ((_ success : Bool ,_ feeds:[ABFeed]) -> Void)) {
        if isInternetAvailable(true) {
            var methodName = "getGlobalFeeds"
            if isGlobalFeeds {
                methodName = "getGlobalFeeds"
            } else {
                methodName = "getFollowerFeeds"
            }
            PFCloud.callFunction(inBackground: methodName, withParameters:["userId": userID , "pageNo":pageNo], block: { (reponse, error) in
                var feeds = [ABFeed]()
                if error != nil { // Error when fetching user with name
                    completionHandler(false , feeds)
                } else if let dataDir = reponse as? [[String: AnyObject]] {
                    if userID.characters.count > 2 {
                        //with userID global feeds liked by userID
                        for object in dataDir {
                            var isliked = false
                            
                            if let likeStatus = object["likeStatus"] as? Int {
                                if (likeStatus == 1){ isliked = true }
                            }
                            
                            if let feed = object["feed"] as? PFObject {
                                feeds.append(ABFeed(pfObject: feed, isLikedByMe: isliked, bittInteractionFlag: object["bittInteractionFlag"] as? Bool, userInteractionFlag: object["userInteractionFlag"] as? Bool))
                            }
                        }
                    }
                    completionHandler(true, feeds)
                } else if let dataDir = reponse as? [PFObject] {
                    for feed in dataDir {
                        feeds.append(ABFeed(pfObject: feed))
                    }
                    completionHandler(true, feeds)
                } else {
                    completionHandler(false, feeds)
                }
            })
        }
    }
    
    func getBitsOfMe(_ userID:String , pageNo: Int , completionHandler : @escaping ((_ success : Bool ,_ feeds:[ABFeed]) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "getBitsOfMe", withParameters: ["userId": userID , "pageNo":pageNo], block: { (response, error) in
                var feeds = [ABFeed]()
                if error != nil { // Error when fetching user with name
                    completionHandler(false , feeds)
                } else if let dataDir = response as? [[String: AnyObject]] {
                    if userID.characters.count > 2{
                        //with userID global feeds liked by userID
                        for object in dataDir {
                            var isliked = false
                            if let likeStatus = object["likeStatus"] as? Int {
                                if (likeStatus == 1){ isliked = true }
                            }
                            if let feed = object["feed"] as? PFObject{
                                feeds.append(ABFeed(pfObject: feed, isLikedByMe: isliked, bittInteractionFlag: object["bittInteractionFlag"] as? Bool, userInteractionFlag: object["userInteractionFlag"] as? Bool))
                            }
                        }
                        
                    } else {
                        for object in dataDir {
                            if let feed = object as? PFObject {
                                feeds.append(ABFeed(pfObject: feed))
                            }
                        }
                    }
                    completionHandler(true, feeds)
                    
                } else {
                    completionHandler(false, feeds)
                }
            })
        }
    }
    
    func searchFeeds(_ searchText :String ,userID:String , pageNo: Int ,completionHandler : @escaping ((_ success : Bool ,_ feeds:[ABFeed],_ users:[ABUser]) -> Void)) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: "searchFeeds", withParameters: ["searchText": searchText, "userId": userID ,"pageNo": pageNo], block: { (response, error) in
                print(response)
                var feeds = [ABFeed]()
                var users = [ABUser]()
                if error != nil { // Error when fetching user with name
                    completionHandler(false , feeds,users)
                } else if let dataDir = response as? [String: AnyObject]  {
                    if let feedarray = dataDir["feeds"] as? [[String: AnyObject]] {
                        for object in feedarray {
                            var isliked = false
                            if let likeStatus = object["likeStatus"] as? Int {
                                if (likeStatus == 1) { isliked = true }
                            }
                            if let feed = object["feed"] as? PFObject {
                                feeds.append(ABFeed(pfObject: feed, isLikedByMe: isliked, bittInteractionFlag: object["bittInteractionFlag"] as? Bool, userInteractionFlag: object["userInteractionFlag"] as? Bool))
                            }
                        }
                    }
                    
                    if let usersarray = dataDir["userList"] as? [[String: AnyObject]] {
                        for object in usersarray {
                            if let user = object["user"] as? PFUser {
                                let user = ABUser(pfUser: user)
                                if let followStatus = object["followStatus"] as? String {
                                    switch followStatus {
                                    case "Follow":
                                        user.relationWithCurrentUser = PersonRelationType.follow
                                    case "Following":
                                        user.relationWithCurrentUser = PersonRelationType.following
                                    case "Requested":
                                        user.relationWithCurrentUser = PersonRelationType.requested
                                    case "Unblock":
                                        user.relationWithCurrentUser = PersonRelationType.unblock
                                    case "CurrentUser":
                                        user.relationWithCurrentUser = PersonRelationType.currentUser
                                        
                                    default:
                                        user.relationWithCurrentUser = PersonRelationType.follow
                                    }
                                }
                                if let count = object["numberofFollowers"] as? Int{
                                    user.numberOfFollowers = count
                                }
                                
                                users.append(user)
                            }
                            
                            //                            var isFollowing = false
                            //                            if let likeStatus = object["isFollowing"] as? Int {
                            //                                if (likeStatus == 1) { isFollowing = true }
                            //                            }
                            //                            if let user = object["user"] as? PFUser {
                            //                                users.append(ABUser(pfUser:user, isfollowing:isFollowing))
                            //                            }
                        }
                    }
                    completionHandler(true , feeds,users)
                } else {
                    completionHandler(false , feeds,users)
                }
            })
        }
    }
    
    func saveFeed(_ title: String, tags: String, image: UIImage, audioDuartionTimer:String, completionHandler: @escaping (_ errorInformation: String?) -> Void) {
        
        if isInternetAvailable(true) {
            //            let imageData = compressImage(image)
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let audioFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String + "/voiceRecording.aac"
            let audioFileData = try? Data(contentsOf: URL(fileURLWithPath: audioFilePath))
            print("imagesize:\(imageData.count) and Audio size:\(audioFileData?.count)")
            let feeding = PFObject(className: "Feeds")
            feeding["bitImage"] =  PFFile(name:"image.jpg", data:imageData)
            feeding["bitAudio"] =  PFFile(name:"voiceRecording.aac", data: audioFileData!)
            feeding["bitTitle"] =  title
            feeding["description"] =  tags
            feeding["postedBy"] =  PFUser.current()!
            feeding["plays"] = 0
            feeding["comments"] = 0
            feeding["likes"] = 0
            feeding["bitDuration"] = audioDuartionTimer
            let strattime =  Date().timeIntervalSince1970
            feeding.saveInBackground{ (succeed, error) -> Void in
                let endtime =  Date().timeIntervalSince1970
                print("Start Time :\(strattime), EndTime:\(endtime) serviceTime :\(endtime -  strattime)")
                if succeed {
                    completionHandler(nil)
                } else {
                    if let error = error {
                        completionHandler(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func findDuplicates(_ key:String, value:String,completionHandler : @escaping (_ isFound: Bool, _ existedUserIdType:String) -> Void) -> Void {
        if isInternetAvailable(true) {
            let query = PFUser.query()
            query!.whereKey(key, equalTo: value)
            query!.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                
                if error != nil { // Error when fetching user with name
                    completionHandler(false, "")
                    
                } else if object == nil { // No user found when fetching user with name
                    
                    completionHandler(false,"")
                    
                } else  {  // Fetch bit user name is success
                    if let getkey = object![key] as? String {
                        // User Found with given name if
                        if (getkey == value) {
                            if object!["facebookId"] != nil {
                                completionHandler(true, "Facebook")
                            } else if object!["twitterId"] != nil {
                                completionHandler(true, "Twitter")
                            } else if object!["googleId"] != nil{
                                completionHandler(true, "Google")
                            } else {
                                completionHandler(true, "Email")
                            }
                        }
                    } else { // User name is not matching - Sign Up
                        completionHandler(false,"")
                    }
                }
            }
        }
    }
    
    func findAllBitUsernames() {
        let query = PFUser.query()
        query!.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if objects?.count > 0 {
                    SharedManager.sharedInstance.allBitUserNames.removeAll()
                    for obj in objects! {
                        SharedManager.sharedInstance.allBitUserNames.append(obj["bitUsername"] as? String ?? "")
                    }
                    //print(SharedManager.sharedInstance.allBitUserNames)
                }
            }
        }
    }
    
    // save bit comments
    func followUser(_ user:ABUser , completionHandler : @escaping ((_ success : Bool) -> Void)) {
        if user.objectId == PFUser.current()?.objectId {
            showAlertOnWindow(message: "You can't follow your own profile!")
            return;
        }
        if isInternetAvailable(true) {
            let com = PFObject(className:"Follow")
            com["user"] = PFUser(withoutDataWithClassName: "_User", objectId: user.objectId)
            com["followedBy"] = PFUser.current()!
            if  (user.isPrivate == true) {
                com["isReqAccept"] = false
            } else {
                com["isReqAccept"] = true
            }
            com.saveInBackground {
                (success: Bool, error: Error?) -> Void in
                if (success) {
                    completionHandler(success)
                } else {
                    // There was a problem, check error.description
                    completionHandler(false)
                }
            }
        }
    }
    
    // is Current user following ABuser
    func isFollowingUser(_ user:ABUser , completionHandler : @escaping (( _ sucess :Bool,_ isfollowing : Bool) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Follow")
            query.whereKey("user", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: user.objectId))
            query.whereKey("followedBy", equalTo: PFUser.current()!)
            query.includeKey("user")
            query.includeKey("followedBy")
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                if error != nil { // Error when fetching user with name
                    completionHandler(false,false)
                } else if object == nil {
                    completionHandler(false,false)
                } else  {
                    if let getkey = (object!["followedBy"] as AnyObject).objectId  {
                        if (getkey == PFUser.current()?.objectId){
                            var isfollow = false
                            if let isfollowing = object!["isReqAccept"] as? Bool{
                                isfollow = isfollowing
                            }
                            completionHandler(true,isfollow)
                        }
                    } else {
                        completionHandler(false,true)
                    }
                }
            }
        }
    }
    
    // is Current user following ABuser
    func aceeptUserReq(_ user:ABUser , completionHandler : @escaping (( _ sucess :Bool,_ isfollowing : Bool) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Follow")
            query.whereKey("followedBy", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: user.objectId))
            query.whereKey("user", equalTo: PFUser.current()!)
            query.includeKey("user")
            query.includeKey("followedBy")
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                
                if error != nil { // Error when fetching user with name
                    completionHandler(false,false)
                } else if object == nil {
                    completionHandler(false,false)
                    
                } else {
                    object!["isReqAccept"] = true
                    object?.saveInBackground()
                    completionHandler(true,true)
                }
            }
        }
    }
    
    func rejectUser(_ user: ABUser, completionHandler: @escaping (_ errorInformation: String?) -> Void) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Follow")
            query.whereKey("user", equalTo: PFUser.current()!)
            query.whereKey("followedBy", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: user.objectId))
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                if let object = object {
                    object.deleteInBackground()
                    completionHandler(nil)
                } else {
                    completionHandler(error?.localizedDescription)
                }
            }
        }
    }
    
    // UnFollow User
    func unFollowUser(_ user:ABUser , completionHandler : @escaping ((_ isfollowing : Bool) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Follow")
            query.whereKey("user", equalTo: PFUser(withoutDataWithClassName: "_User", objectId: user.objectId))
            query.whereKey("followedBy", equalTo: PFUser.current()!)
            query.includeKey("user")
            query.includeKey("followedBy")
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                
                if error != nil { // Error when fetching user with name
                    completionHandler(false)
                    
                } else if object == nil {
                    completionHandler(false)
                    
                } else {
                    if let getkey = (object!["followedBy"] as AnyObject).objectId  {
                        if (getkey == PFUser.current()?.objectId){
                            object?.deleteEventually()
                            completionHandler(true)
                        }
                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
    }
    
    
    // MARK:- Notifications
    
    func getUserNotifications( _ completionHandler : @escaping ((_ notifications : [ABNotification]?, _ errorInformation: String?) -> Void)) {
        if isInternetAvailable(true) {
            let query = PFQuery(className:"Notification")
            
            query.includeKey("toUser")
            query.includeKey("fromUser")
            query.includeKey("bitId")
            query.includeKey("bitId.postedBy")
            
            query.whereKey("toUser", equalTo: PFUser(withoutDataWithObjectId: PFUser.current()?.objectId))
            
            query.order(byDescending: "createdAt")
            
            query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    var notificationsArray = [ABNotification]()
                    print("Successfully retrieved \(objects!.count) scores.")
                    if let objects = objects {
                        for object in objects {
                            let notificaiton = ABNotification(pfObject: object)
                            if notificaiton.hasValidData {
                                notificationsArray.append(notificaiton)
                            }
                        }
                        completionHandler(notificationsArray, nil)
                    }
                } else {
                    print("Error: \(error!._userInfo)")
                    completionHandler(nil, error!.localizedDescription)
                }
            }
        }
    }
    
    func getUserNotificationsCount() {
        if isInternetAvailable(true) {
            if let userid = PFUser.current()?.objectId {
                let query = PFQuery(className:"Notification")
                query.whereKey("toUser", equalTo: PFUser(withoutDataWithObjectId:userid))
                query.whereKey("isRead", equalTo: false)
                query.includeKey("toUser")
                query.includeKey("fromUser")
                query.includeKey("bitId")
                query.includeKey("bitId.postedBy")
                query.countObjectsInBackground(block: { (count, error) -> Void in
                    if error == nil {
                        SharedManager.sharedInstance.notificationCount = Int(count)
                    }
                })
            } else {
                SharedManager.sharedInstance.notificationCount = 0
            }
        }
    }
    
    func getRequestsInformation(_ completionHandler: @escaping ((_ errorInformation: String?, _ users: [ABUser]?) -> Void)) {
        let query = PFQuery(className:"Follow")
        query.includeKey("followedBy")
        
        //        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: ABUserManager.sharedInstance.currentUser!.objectId))
        query.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: PFUser.current()!.objectId))
        query.whereKey("isReqAccept", equalTo: false)
        
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            var requestedUsersArray = [ABUser]()
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                if let objects = objects {
                    for object in objects {
                        if let userObj = object["followedBy"] as? PFUser {
                            requestedUsersArray.append(ABUser(pfUser: userObj))
                        }
                    }
                    completionHandler(nil, requestedUsersArray)
                } else {
                    completionHandler("No data found!", nil)
                }
            } else {
                print("Error: \(error!._userInfo)")
                completionHandler(error?.localizedDescription, nil)
            }
        }
    }
    
    //
    
    //MARK: push Notifiaction methods
    
    func likesPush(_ feed:ABFeed) {
        let query = PFInstallation.query()
        if let userId = feed.postedBy?.objectId {
            query?.whereKey("user", equalTo:PFUser(withoutDataWithObjectId:userId))
            let push = PFPush()
            push.setQuery(query as! PFQuery<PFInstallation>?)
            let currentUserNameInPush = PFUser.current()?["bitUsername"] as? String ?? ""
            let message = "\(currentUserNameInPush.chopPrefix()) liked your post \(feed.bitTitle ?? "")"
            //            let pushDir = ["statusFrom":commentedUserName,"alert":message,"badge":"Increment","sound":"chime"]
            //            push.setData(pushDir)
            //            push.sendPushInBackground()
            self.saveNotification("Like", toUserId: userId, bitId: feed.objectId!, isFollow: true)
            
            if (feed.postedBy?.isNotifyLikes == true ) {
                PFPush.sendMessageToQuery(inBackground: query as! PFQuery<PFInstallation>, withMessage: message)
            }
        }
    }
    
    func tagedpush(_ feedTittle:String, message:String) {
        if message.contains("@") {
            let myArray : [String] = message.components(separatedBy: " ")
            var bitUsernames = [String]()
            for obj in myArray {
                if ((obj.characters.first == "@") && (obj.characters.count > 5)) {
                    bitUsernames.append(obj)
                }
            }
            let query = PFInstallation.query()
            query?.whereKey("bitUsername", equalTo:bitUsernames)
            let push = PFPush()
            push.setQuery(query as! PFQuery<PFInstallation>?)
            let currentUserNameInPush = PFUser.current()?["bitUsername"] as? String ?? ""
            let message = "\(currentUserNameInPush.chopPrefix()) tagged on Bitt \(feedTittle)"
            // let pushDir = ["statusFrom":commentedUserName,"alert":message,"badge":"Increment","sound":"chime"]
            //            push.setData(pushDir)
            //            push.sendPushInBackground()
            
            PFPush.sendMessageToQuery(inBackground: query as! PFQuery<PFInstallation>, withMessage: message)

        }
    }
    
    func commentPush(_ feed:ABFeed) {
        let query = PFInstallation.query()
        if let userId = feed.postedBy?.objectId {
            query?.whereKey("user", equalTo:PFUser(withoutDataWithObjectId:userId))
            let currentUserNameInPush = PFUser.current()?["bitUsername"] as? String ?? ""
            let message = "\(currentUserNameInPush.chopPrefix()) commented on your Bitt \(feed.bitTitle ?? "")"
            if (feed.postedBy?.isNotifyComments == true ) {
                PFPush.sendMessageToQuery(inBackground: query as! PFQuery<PFInstallation>, withMessage: message)

            }
            self.saveNotification("Comment", toUserId: userId, bitId: feed.objectId!, isFollow: true)
        }
    }
    
    //    func commentPush(feed:ABFeed) {
    //        let query = PFInstallation.query()
    //        if let userId = feed.postedBy?.objectId {
    //            query?.whereKey("user", equalTo:PFUser(withoutDataWithObjectId:userId))
    //            let push = PFPush()
    //            push.setQuery(query)
    //            let commentedUserName = PFUser.currentUser()?["fullName"] as? String ?? PFUser.currentUser()?["bitUsername"] as? String ?? ""
    //            let message = "\(commentedUserName) commented on your Bitt \(feed.bitTitle ?? "")"
    //            let pushDir = ["statusFrom":commentedUserName,"alert":message,"badge":"Increment","sound":"chime"]
    //            push.setData(pushDir)
    //            if (feed.postedBy?.isNotifyComments == true ) {
    //                push.sendPushInBackground()
    //                //            PFPush.sendPushMessageToQueryInBackground(query!, withMessage: message) { (sucess, error) -> Void in
    //                //                if sucess{
    //                //                    print("push sent succesfully")
    //                //                }else{
    //                //                    print(error?.localizedDescription)
    //                //                }
    //                //
    //                //            }
    //            }
    //            self.saveNotification("Comment", toUserId: userId, bitId: feed.objectId!, isFollow: true)
    //        }
    //    }
    
    func followPush(_ user:ABUser) {
        let query = PFInstallation.query()
        if let userId = user.objectId{
            query?.whereKey("user", equalTo:PFUser(withoutDataWithObjectId:userId))
            let push = PFPush()
            push.setQuery(query as! PFQuery<PFInstallation>?)
            let currentUserNameInPush = PFUser.current()?["bitUsername"] as? String ?? ""
            var message = ""
            if (user.isPrivate == true) {
                message = "\(currentUserNameInPush.chopPrefix()) Requested to follow you"
                self.saveNotification("Follow", toUserId: userId, bitId:"", isFollow: false)
            } else {
                message = "\(currentUserNameInPush.chopPrefix()) Started following you"
                self.saveNotification("Follow", toUserId: userId, bitId:"", isFollow: true)
            }
            
            // let pushDir = ["statusFrom":commentedUserName,"alert":message,"badge":"Increment","sound":"chime"]
            //  push.setData(pushDir)
            // push.sendPushInBackground()
            
            if (user.isNotifyNewFollowers == true ) {
                PFPush.sendMessageToQuery(inBackground: query as! PFQuery<PFInstallation>, withMessage: message)
            }
        }
    }
    
    func saveNotification(_ type:String,toUserId:String,bitId:String,isFollow:Bool) {
        if isInternetAvailable(true) {
            let notification = PFObject(className: "Notification")
            notification["toUser"] =  PFUser(withoutDataWithObjectId:toUserId)
            notification["fromUser"] = PFUser.current()!
            notification["bitId"] =  PFObject(withoutDataWithClassName: "Feeds", objectId: bitId)
            notification["type"] =  type
            notification["isFollowing"] = isFollow
            notification["isRead"] = false
            
            notification.saveInBackground{ (succeed, error) -> Void in
                if succeed {
                    print("notification saved")
                } else {
                    print("notification saving fail")
                }
            }
        }
    }
    
    // MARK:- Feedback
    
    func saveInfoInFeedbackTable(_ feedback: ABFeedback) {
        if isInternetAvailable(false) {
            let feeding = PFObject(className: "Feedback")
            feeding["feedbackText"] =  feedback.feedbackText ?? ""
            feeding["type"] =  feedback.type?.rawValue ?? ""
            
            if let currentUser = PFUser.current() {
                feeding["reportedBy"] = currentUser
            }
            
            if let feed = feedback.feed_Flagged {
                feeding["feed_Flagged"] =  PFObject(withoutDataWithClassName: "Feeds", objectId: feed.objectId)
            }
            
            if let user = feedback.user_Flagged {
                feeding["user_Flagged"] =  PFObject(withoutDataWithClassName: "_User", objectId: user.objectId)
            }
            
            feeding.saveInBackground{ (succeed, error) -> Void in
                if succeed {
                    print("Success in save InfoIn Feedback Table, ObjectId: \(feeding.objectId)")
                } else {
                    if let error = error {
                        print("Error in save InfoIn Feedback Table, feedbackText: \(feedback.feedbackText ?? "")")
                        print("Error Info: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func blockOrUnblockTheUser(_ user: ABUser, block: Bool, completionHandler: @escaping (_ errorInformation: String?) -> Void) {
        if isInternetAvailable(true) {
            PFCloud.callFunction(inBackground: block ? "blockUser":"unblockUser", withParameters: ["currentUserObjectId": (PFUser.current()?.objectId)!, "userObjectId": user.objectId!], block: { (response, error) in
                if error == nil {
                    ABUserManager.sharedInstance.refreshCurrentUser({ (errorInformation) -> Void in
                        completionHandler(errorInformation)
                    })
                } else {
                    print("Error in block Or Unblock The User: \(error!)")
                    completionHandler(error?.localizedDescription)
                }
            })
        }
    }
    
    // MARK:-
}
