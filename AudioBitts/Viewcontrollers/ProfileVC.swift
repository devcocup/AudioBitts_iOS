//
//  ProfileVC.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import SDWebImage
import TwitterKit
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



enum ProfileVCNavigationSource {
    case sideMenuVC, exploreVC, notificationsVC, requestsVC, followersOrFollowingVC, searchVC
}

enum BittsCategory {
    case myBitts, bittsOfMe
}

class ProfileVC: BaseMainVC {
    
    @IBOutlet weak var feedsTableView: UITableView!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var myBittsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var topView: GradientView!
    @IBOutlet weak var headerGradientView: GradientView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileNameLabelOnTop: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var followButton: ABFollowButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var privateUserMessageView: UIView!
    @IBOutlet weak var emptyMyBittsForOwnProfileView: UIView!
    @IBOutlet weak var noBittsForOtherProfilesView: UIView!
    @IBOutlet weak var emptyBittsOfMeforOwnProfileView: UIView!
    
    var feedsArray : [ABFeed] = []
    var currentPage = 0
    var nextpage = 0
    var isFollow = false
    var userInformation: ABUser?
    var isCurrentUserFollowingMe = false
    
    var recordVC: RecordVC!
    
    var isFetchInQueue :Bool = false  // wait for before fetch call complete
    var stopGetingFeeds :Bool = false // when Geting feeds count is 0 stop auto fech feeds
    var isLikeInQueue :Bool = false // checking for wait for Call back
    
    var audioPlayer: AVAudioPlayer!
    var currentPlayingIndex: Int?
    var followersArray = [ABUser]()
    var followedByArray = [ABUser]()
    var bittsOfMe : [ABFeed] = []
    var myBitts : [ABFeed] = []
    
    var profileHeaderContainer: UIView?
    var profileHeaderVCInstance: ProfileHeaderVC?
    let firstCellHeight: CGFloat = 275 - 64
    
    var likeNotification:ABFeed!
    var isNavigated = false
    
    //  var refreshControl:UIRefreshControl!
    
    var profileNavigationSource = ProfileVCNavigationSource.sideMenuVC
    var bittCategory = BittsCategory.myBitts
    
    //weak var delegate: ExploreVCDelegate?
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emptyBittsOfMeforOwnProfileView.isHidden = true
        
        if profileNavigationSource == .sideMenuVC {
            moreButton.isHidden = true
        } else if userInformation?.objectId != PFUser.current()?.objectId {
            moreButton.isHidden = false
            moreButton.addTarget(self, action: #selector(ProfileVC.moreButtonAction), for: UIControlEvents.touchUpInside)
        } else {
            moreButton.isHidden = true
        }
        
        feedsTableView.register(UINib(nibName: "FeedsTVCell", bundle: nil), forCellReuseIdentifier: "FeedsTVCellIdentifier")
        //        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing....")
        //        refreshControl.tintColor = UIColor.navBarEndColor()
        //        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        //        self.feedsTableView.addSubview(refreshControl)
        headerGradientView.colors = [UIColor.navBarStartColor(), UIColor.navBarEndColor()]
        headerGradientView.direction = GradientView.Direction.vertical
        
        topView.colors = [UIColor.navBarStartColor(), UIColor.navBarEndColor()]
        topView.direction = GradientView.Direction.vertical
        topView.isHidden = true
        profileNameLabelOnTop.isHidden = true
        self.followersCountLabel.text = "0"
        self.followingCountLabel.text = "0"
        self.myBittsCountLabel.text = "0"
        
        if isFollow {
            followButton.isHidden = false
            configureBackButton()
            menuButton.setImage(UIImage(named: "back"), for: UIControlState())
            menuButton.addTarget(self, action: "backBtnClicked", for: UIControlEvents.touchUpInside)
            if (userInformation != nil) {
                showIndicator()
                HeyParse.sharedInstance.isFollowingUser(userInformation!, completionHandler: { (sucess,isfollowing) -> Void in
                    self.hideIndicator()
                    if sucess {
                        if isfollowing {
                            self.isCurrentUserFollowingMe = true
                            self.followButton.backgroundColor = UIColor.white
                            self.followButton.setTitle("FOLLOWING", for: UIControlState())
                        } else {
                            self.followButton.setTitle("REQUESTED", for: UIControlState())
                            self.followButton.backgroundColor =  UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
                        }
                    }
                })
            }
        } else {
            if isNavigated == true {
                configureBackButton()
                menuButton.setImage(UIImage(named: "back"), for: UIControlState())
                menuButton.addTarget(self, action: "backBtnClicked", for: UIControlEvents.touchUpInside)
            } else {
                followButton.isHidden = true
                editProfileButton.isHidden = false
                menuButton.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            }
            if (PFUser.current() != nil) {
                userInformation = ABUser(pfUser: PFUser.current()!)
            }
        }
        
        let name =  userInformation?.bitUserName?.chopPrefix() ?? "Welcome"
        profileNameLabel.text = name
        profileNameLabelOnTop.text = name
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        setProfilePic(on: profileImageView, user: userInformation, fromSideMenu: false)
        
        if profileNavigationSource == .sideMenuVC {
            dealWithActivityNotificationsUI(menuButton)
        }
        
        dealWithFollowBtnForBlockOrUnblockStatus()
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        print("clicked")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if (userInformation != nil) {
            
            //            HeyParse.sharedInstance.findOutCurrentUserRelationWithUsers([], completionHandler: { (refreshedFollowersArray, errorInfo) -> Void in
            //
            //            })
            
            HeyParse.sharedInstance.getFollowerAndFollowingUsers(userInformation!, completionHandler: { (followers, following, errorInfo) -> Void in
                if let errorInfo = errorInfo {
                    showAlert("Error!", message: errorInfo, on: self)
                    return;
                }
                
                guard let followers = followers else { print("followers is nil"); return }
                guard let following = following else { print("following is nil"); return }
                
                self.followersCountLabel.text = String(followers.count)
                self.followingCountLabel.text = String(following.count)
                self.followersArray = followers
                self.followedByArray = following
            })
            
            fetchFeeds()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTheAudioPlayer()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    override func foundModificationsInUserActivityNotifications() {
        if profileNavigationSource == .sideMenuVC {
            if notificationsCountLabel == nil { // 'notificationsCountLabel' is not added yet, So adding it
                dealWithActivityNotificationsUI(menuButton)
            } else { // 'notificationsCountLabel' is added already, So updating the count
                updateNotificationsCountInfo()
            }
        }
    }
    
    func dealWithFollowBtnForBlockOrUnblockStatus() {
        // Block or Unblock
        if ABUserManager.sharedInstance.checkInBlockedUsers(userInformation) || userInformation?.objectId == PFUser.current()?.objectId {
            changeFollowBtnStatus(PersonRelationType.follow)
            
            followButton.isEnabled = false
            followButton.alpha = 0.3
        } else {
            followButton.isEnabled = true
            followButton.alpha = 1
        }
    }
    
    //MARK:- Fetch data
    func fetchFeeds() {
        if let isPrivate = userInformation?.isPrivate, isPrivate && PFUser.current()!.objectId != userInformation!.objectId {
            privateUserMessageView.isHidden = false
            feedsTableView.isScrollEnabled = false
            return;
        } else {
            privateUserMessageView.isHidden = true
            feedsTableView.isScrollEnabled = true
        }
        
        isFetchInQueue = true
        if bittCategory == .myBitts {
            if let  userID = PFUser.current()!.objectId {
                if let profileID = userInformation?.objectId {
                    print("userID: \(userID)")
                    print("profileID: \(profileID)")
                    HeyParse.sharedInstance.getMyFeeds(userID,profileID:profileID, pageNo: currentPage) { (sucess , feeds) -> Void in
                        //self.refreshControl.endRefreshing()
                        self.isFetchInQueue = false
                        //                        self.hideIndicator()
                        if sucess {
                            if (self.currentPage == 0) {
                                self.feedsArray.removeAll()
                                self.myBitts.removeAll()
                            }
                            if (feeds.count == 0) {
                                self.stopGetingFeeds = true
                            }
                            if self.isNavigated == true {
                                self.feedsArray.append(self.likeNotification)
                            } else {
                                self.feedsArray = self.myBitts
                            }
                            self.myBitts.append(contentsOf: feeds)
                            self.myBitts.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
                            self.myBittsCountLabel.text = String(self.myBitts.count)
                            self.feedsArray = self.myBitts
                        }
                        self.reloadFeedsTableView()
                    }
                }
            }
        } else {
            if let userID = userInformation?.objectId {
                HeyParse.sharedInstance.getBitsOfMe(userID, pageNo: currentPage) { (sucess , feeds) -> Void in
                    // self.refreshControl.endRefreshing()
                    self.isFetchInQueue = false
                    //                    self.hideIndicator()
                    if sucess {
                        if (self.currentPage == 0) {
                            self.feedsArray.removeAll()
                            self.bittsOfMe.removeAll()
                        }
                        if (feeds.count == 0) {
                            self.stopGetingFeeds = true
                        }
                        self.bittsOfMe.append(contentsOf: feeds)
                        self.bittsOfMe.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
                    }
                    self.feedsArray = self.bittsOfMe
                    self.reloadFeedsTableView()
                }
            }
        }
    }
    
    func reloadFeedsTableView() {
        var footerHeight: CGFloat?
        let screenFrame = UIScreen.main.bounds
        if feedsArray.count == 0 {
            footerHeight = screenFrame.height - 115
        } else if feedsArray.count == 1 {
            footerHeight = (screenFrame.height / 2) - 115
        }
        if let height = footerHeight {
            let emptyFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screenFrame.width, height: height))
            //            emptyFooterView.backgroundColor = UIColor.orangeColor()
            emptyFooterView.backgroundColor = UIColor.clear
            self.feedsTableView.tableFooterView = emptyFooterView
        } else {
            self.feedsTableView.tableFooterView = nil
        }
        
        if feedsArray.count == 0 {
            feedsTableView.isScrollEnabled = false
            if userInformation?.objectId == PFUser.current()?.objectId {
                noBittsForOtherProfilesView.isHidden = true
                emptyBittsOfMeforOwnProfileView.isHidden = true
                switch bittCategory {
                case .myBitts:
                    emptyMyBittsForOwnProfileView.isHidden = false
                    feedsTableView.setContentOffset(CGPoint(x: 0,y: 0), animated: false)
                case .bittsOfMe:
                    emptyMyBittsForOwnProfileView.isHidden = true
                    emptyBittsOfMeforOwnProfileView.isHidden = false
                }
            } else {
                noBittsForOtherProfilesView.isHidden = false
            }
        } else {
            feedsTableView.isScrollEnabled = true
            emptyMyBittsForOwnProfileView.isHidden = true
            emptyBittsOfMeforOwnProfileView.isHidden = true
            noBittsForOtherProfilesView.isHidden = true
        }
        self.feedsTableView.reloadData()
    }
    
    func showFollowVC(_ type: FollowersOrFollowingType) {
        let follow = storyboard?.instantiateViewController(withIdentifier: "FollowersOrFollowingVC_ID") as! FollowersOrFollowingVC
        follow.infoType = type
        follow.users = type == .followers ? followersArray : followedByArray
        navigationController?.pushViewController(follow, animated: true)
    }
    
    //MARK:- Player functions
    func playUsingAudioPlayer(_ index: Int, path: String) {
        if currentPlayingIndex == index {
            stopTheAudioPlayer()
            return;
        }
        if let i = currentPlayingIndex {
            currentPlayingIndex = index
            reloadCell(i)
        } else {
            currentPlayingIndex = index
        }
        //Update play count to database
        let feed = feedsArray[currentPlayingIndex!]
        feed.plays = (feed.plays ?? 0) + 1
        if let feedId = feedsArray[currentPlayingIndex!].objectId {
            HeyParse.sharedInstance.updatePlayCount(feedId, completionHandler: { (success , feed) -> Void in
                print(success)
            })
        }
        
        reloadCell(currentPlayingIndex!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Catch error in playUsingAudioPlayer")
        }
    }
    
    func stopTheAudioPlayer() {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        
        if let index = currentPlayingIndex {
            currentPlayingIndex = nil
            reloadCell(index)
        }
    }
    
    func setDownloadingStatusFor(_ indexPath: IndexPath) {
        if let cell = feedsTableView.cellForRow(at: indexPath) as? FeedsTVCell {
            cell.playImageView.image = UIImage(named: "downloading")
        }
    }
    
    func reloadCell(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = feedsTableView.cellForRow(at: indexPath) as? FeedsTVCell {
            updateTheCell(cell, indexPath: indexPath)
        }
        
        //        let selectedCarIndexPath = NSIndexPath(forRow: index, inSection: 0)
        //        feedsTableView.reloadRowsAtIndexPaths([selectedCarIndexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func moreButtonAction(){
        let vc = VKActionController()
        if (PFUser.current() != nil) {
            
            // Block and Unblock
            let isAlreadyBlocked = ABUserManager.sharedInstance.checkInBlockedUsers(userInformation)
            
            vc.addAction(VKAction(title: isAlreadyBlocked ? "Unblock user" : "Block user", image: UIImage(named: "block"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                in
                self.followButton.isUserInteractionEnabled = false
                HeyParse.sharedInstance.blockOrUnblockTheUser(self.userInformation!, block: !isAlreadyBlocked, completionHandler: { (errorInformation) -> Void in
                    self.followButton.isUserInteractionEnabled = true
                    self.dealWithFollowBtnForBlockOrUnblockStatus()
                })
                })
            //
            
            vc.addAction(VKAction(title: "Report user", image: UIImage(named: "abuse"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                in
                //self.trackScreen(GASNFeedBack)
                self.showFeedBackVC(nil, user: self.userInformation)
                })
            
            vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
                
                })
            
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    //MARK:- IBActions
    @IBAction func editProfileButtonAction(_ sender: AnyObject) {
        //trackScreen(GASNCreateAccount)
        let createAccountVC = storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC_ID") as! CreateAccountVC
        createAccountVC.user = userInformation
        createAccountVC.navigationSource = AccountEditNavigationSource.profile
        navigationController?.pushViewController(createAccountVC, animated: true)
    }
    
    @IBAction func followButtonAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "REQUESTED" {
            print("Do nothing.")
            return;
        }
        
        if (userInformation != nil) {
            if !isCurrentUserFollowingMe {
                showIndicator()
                var count = getInt(self.followersCountLabel.text)
                if  count >= 0 {
                    count += 1
                    self.followersCountLabel.text = String(count)
                    self.followersArray.append(ABUser(pfUser: PFUser.current()!))
                }
                HeyParse.sharedInstance.followUser(userInformation!, completionHandler: { (success) -> Void in
                    self.hideIndicator()
                    if success {
                        self.isCurrentUserFollowingMe = true
                        //                        self.followButton.backgroundColor = UIColor.whiteColor()
                        if (self.userInformation?.isPrivate == true){
                            self.followButton.setTitle("REQUESTED", for: UIControlState())
                            self.followButton.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
                        } else {
                            self.followButton.setTitle("FOLLOWING", for: UIControlState())
                            self.followButton.backgroundColor = UIColor.white
                        }
                        
                        // sending push for feed user
                        HeyParse.sharedInstance.followPush(self.userInformation!)
                    }
                })
            } else {
                showIndicator()
                var count = getInt(self.followersCountLabel.text)
                if  count >= 1 {
                    count -= 1
                    self.followersCountLabel.text = String(count)
                    followersArray = followersArray.filter({ (obj) -> Bool in
                        if (obj.objectId != PFUser.current()!.objectId){
                            return true
                        }
                        return false
                    })
                }
                HeyParse.sharedInstance.unFollowUser(userInformation!, completionHandler: { (success) -> Void in
                    self.hideIndicator()
                    if success {
                        self.changeFollowBtnStatus(PersonRelationType.follow)
                    }
                })
            }
        }
    }
    
    func changeFollowBtnStatus(_ relation: PersonRelationType) {
        if relation == PersonRelationType.follow {
            self.isCurrentUserFollowingMe = false
            self.followButton.backgroundColor = UIColor.black
            self.followButton.setTitle("+ FOLLOW", for: UIControlState())
        }
    }
    
    @IBAction func followingButtonAction(_ sender: AnyObject) {
        if (followedByArray.count > 0) {
            //trackScreen(GASNFollowing)
            showFollowVC(.following)
        }
    }
    
    @IBAction func followerButtonAction(_ sender: AnyObject) {
        if (followersArray.count > 0) {
            //trackScreen(GASNFollowers)
            showFollowVC(.followers)
        }
    }
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if PFUser.current() != nil {
            SharedManager.sharedInstance.canShowLikePopUp = false
            
            // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.sharingDone(_:)), name: NSNotification.Name(rawValue: "sharingStatus"), object: nil)
            
            recordVC = storyboard?.instantiateViewController(withIdentifier: "RecordVC_ID") as! RecordVC
            present(recordVC, animated: true, completion: nil)
        } else {
            //showAlert("Login required!", message: "Please login to create a AudioBitt", on: self)
            //            showSignUpVC()
        }
    }
    
    // MARK:- NSNotification
    func sharingDone(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sharingStatus"), object: nil)
        let status = notification.userInfo!["succeeded"] as! Bool
        if status {
            
        }
        recordVC.dismiss(animated: true, completion: nil)
    }
    
}

// MARK:- ProfileHeaderVCDelegate
extension ProfileVC: ProfileHeaderVCDelegate {
    func myBitsButtonClicked() {
        if !isFetchInQueue {
            stopTheAudioPlayer()
            bittCategory = .myBitts
            stopGetingFeeds = false
            currentPage = 0
            //            if feedsTableView.numberOfRowsInSection(0) > 0 {
            //                self.feedsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            //            }
            fetchFeeds()
        }
    }
    
    func bitsOfMeButtonClicked() {
        if !isFetchInQueue {
            stopTheAudioPlayer()
            bittCategory = .bittsOfMe
            stopGetingFeeds = false
            currentPage = 0
            //            if feedsTableView.numberOfRowsInSection(0) > 0 {
            //                self.feedsTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
            //            }
            fetchFeeds()
        }
    }
}

extension ProfileVC: FeedsCellDelegate {

    func searchHashtags(string: String) {
        
    }
    
    func likeButtonClicked(_ indexPath: IndexPath) {
        let currentfeed = feedsArray[indexPath.row]
        if let userId = PFUser.current()?.objectId {
            if let feedUserID = currentfeed.postedBy?.objectId {
                if  (feedUserID != userId) {
                    //self.trackEvent(GASNProfile, action: GAEVLike, label: currentfeed.bitTitle!, value: nil)
                    if !isLikeInQueue {
                        isLikeInQueue = true
                        if !currentfeed.isLikedByMe {
                            currentfeed.likes = (currentfeed.likes ?? 0) + 1
                            currentfeed.isLikedByMe = true
                        } else {
                            if currentfeed.likes > 0 {
                                currentfeed.likes = (currentfeed.likes ?? 0) - 1
                                currentfeed.isLikedByMe = false
                            }
                        }
                        self.reloadCell(indexPath.row)
                        HeyParse.sharedInstance.updateLikeCount(currentfeed.objectId!, isLiked: currentfeed.isLikedByMe, completionHandler: { (success, feed) -> Void in
                            self.isLikeInQueue = false
                            if success {
                                self.feedsArray[indexPath.row] = feed!
                                self.feedsArray[indexPath.row].isLikedByMe = currentfeed.isLikedByMe
                                self.reloadCell(indexPath.row)
                                if currentfeed.isLikedByMe {
                                    HeyParse.sharedInstance.likesPush(currentfeed)
                                }
                            }
                        })
                    }
                } else {
                    //showAlert("", message: "You can't like your own AudioBitts", on: self)
                }
            }
        }else{
            showAlert("Hi Guest!!", message: "Please login to like", on: self)
        }
    }
    
    func commentButtonClicked(_ indexPath: IndexPath) {
        //trackScreen(GASNComment)
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC_ID") as! CommentVC
        commentVC.bit = feedsArray[indexPath.row]
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func playButtonClicked(_ indexPath: IndexPath) {
        let feed = feedsArray[indexPath.row]
        //self.trackEvent(GASNProfile, action: GAEVPlay, label: feed.bitTitle!, value: nil)
        
        if let path = FileManager.sharedInstance.checkIfExists(feed.objectId!) {
            playUsingAudioPlayer(indexPath.row, path: path)
        }
        else {
            setDownloadingStatusFor(indexPath)
            feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
                if let audioData = data{
                    if let path = FileManager.sharedInstance.saveFile(feed.objectId!, data: audioData){
                        self.playUsingAudioPlayer(indexPath.row, path: path)
                    }
                }
            })
        }
    }
    
    func shareButtonClicked(_ indexPath: IndexPath) {
        let vc = VKActionController()
        let feed = feedsArray[indexPath.row]
        let editVC = storyboard?.instantiateViewController(withIdentifier: "ShareVC_ID") as! ShareVC
        editVC.isEdit = true
        editVC.complettionHandler = { (title, desc) -> Void in
            feed.bitTitle = title.text
            feed.bitDescription = desc.text
            var query = PFQuery(className:"Feeds")
            query.getObjectInBackground(withId: feed.objectId!) {
                (bitt: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error ?? "Error editing the Bitt")
                } else if let bitt = bitt {
                    bitt["bitTitle"] = title.text
                    bitt["description"] = desc.text
                    bitt.saveInBackground()
                    self.fetchFeeds()
                }
            }
        self.navigationController?.popViewController(animated: true)
        }
        

        
        func configureReportAbuseOption() {
            vc.addAction(VKAction(title: "Report Abuse", image: UIImage(named: "abuse"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                in
                //self.trackScreen(GASNFeedBack)
                self.showFeedBackVC(feed)
            })
            
//            vc.addAction(VKAction(title: "Share to Twitter", image: nil, color: UIColor.white, cancelTitle: "") {
//                (action) -> Void in
//
//                if FileManager.sharedInstance.isAudioFileExists(feed.objectId!) {
//                    self.shareToTwitter(feed: feed)
//                } else {
//                    feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
//                        if let audioData = data {
//                            if FileManager.sharedInstance.isSaveFileSuccess(feed.objectId!, data: audioData) {
//                                self.shareToTwitter(feed: feed)
//                            }
//                        }
//                    })
//                }
//            })
            
            vc.addAction(VKAction(title: "Share to other...", image: nil, color: UIColor.white, cancelTitle: "") {
                (action) -> Void in
                if FileManager.sharedInstance.isAudioFileExists(feed.objectId!) {
                    self.shareToOthers(feed: feed)
                } else {
                    feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
                        if let audioData = data {
                            if FileManager.sharedInstance.isSaveFileSuccess(feed.objectId!, data: audioData) {
                                self.shareToOthers(feed: feed)
                            }
                        }
                    })
                }
            })
            
            vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
                
            })
            present(vc, animated: true, completion: nil)
        }
        
        
        if (PFUser.current() != nil) {
            if PFUser.current()?.objectId != feed.postedBy?.objectId {
                configureReportAbuseOption()
            } else {
                    vc.addAction(VKAction(title: "Edit", image: UIImage(named: "edit"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
                    //let alert = UIAlertController(title: "", message: "Edit Bitt?", preferredStyle: UIAlertControllerStyle.alert)
                    //alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                        //self.dismiss(animated: true, completion: nil)
                    //}))
                    //alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        //call to navigate to editVC
                        self.navigationController?.pushViewController(editVC, animated: true)
                    //}))
                    //self.present(alert, animated: true, completion: nil)
                    })
                    vc.addAction(VKAction(title: "Delete", image: UIImage(named: "delete"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
                    
                    let alert = UIAlertController(title: "", message: "Delete Bitt?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        
                        let bit = PFObject(className: "Feeds")
                        bit.objectId = feed.objectId
                        
                        bit.deleteInBackground(block: { (sucess, error) -> Void in
                            if sucess {
                                self.feedsArray.remove(at: indexPath.row)
                                self.feedsTableView.reloadData()
                                showAlert("Deleted", message: "", on: self)
                            } else {
                                showAlert("Error!!", message: "Try again", on: self)
                            }
                        })
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            
//                vc.addAction(VKAction(title: "Share to Twitter", image: UIImage(named: "share"), color: UIColor.white, cancelTitle: "") {
//                    (action) -> Void in
//                    
//                    if FileManager.sharedInstance.isAudioFileExists(feed.objectId!) {
//                        self.shareToTwitter(feed: feed)
//                    } else {
//                        feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
//                            if let audioData = data {
//                                if FileManager.sharedInstance.isSaveFileSuccess(feed.objectId!, data: audioData) {
//                                    self.shareToTwitter(feed: feed)
//                                }
//                            }
//                        })
//                    }
//                })
                
                vc.addAction(VKAction(title: "Share to Other...", image: UIImage(named: "share"), color: UIColor.white, cancelTitle: "") {
                    (action) -> Void in
                    if FileManager.sharedInstance.isAudioFileExists(feed.objectId!) {
                        self.shareToOthers(feed: feed)
                    } else {
                        feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
                            if let audioData = data {
                                if FileManager.sharedInstance.isSaveFileSuccess(feed.objectId!, data: audioData) {
                                    self.shareToOthers(feed: feed)
                                }
                            }
                        })
                    }
                })
                
                vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
                    
                })
                present(vc, animated: true, completion: nil)
            }
        } else {
            configureReportAbuseOption()
        }
    }
    
    func profilePicButtonClicked(_ IndexPath: Foundation.IndexPath) {
        print("Profile Pic Button Clicked")
    }
    
    
    func addWatermarkImage(image: UIImage) -> UIImage {
        //        let scale = image.size.width/playImageView.frame.size.width
        let watermarkImage = UIImage(named: "watermark")
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        watermarkImage?.draw(in: CGRect(x: image.size.width-(watermarkImage?.size.width)!-20, y: image.size.height-(watermarkImage?.size.height)!-20, width: (watermarkImage?.size.width)!, height: (watermarkImage?.size.height)!))
        let result: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    func shareToTwitter(image: UIImage, data: Data) {
        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            DispatchQueue.main.async {
                let composer = TWTRComposerViewController.init(initialText: "Great App!", image: image, videoData: data)
                composer.delegate = self as? TWTRComposerViewControllerDelegate
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async(execute: {
                TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                    if (session != nil) {
                        let composer = TWTRComposerViewController.init(initialText: "Great App!", image: image, videoData: data)
                        composer.delegate = self as? TWTRComposerViewControllerDelegate
                        self.present(composer, animated: true, completion: nil)
                    } else {
                        NSLog("--------------------")
                        NSLog(error.debugDescription)
                    }
                })
            })
        }
    }
    
    func shareToTwitter(feed: ABFeed) {
        let url = URL(string: (feed.bitImage?.url!)!)
        let data = try? Data(contentsOf: url!)
        let mergedImage = self.addWatermarkImage(image: UIImage(data: data!)!)
        VideoCreator.sharedInstance.createMovieWithSingleImageAndMusic(image: mergedImage, audioFileURL: FileManager.sharedInstance.audioFileURL(feed.objectId!)!, assetExportPresetQuality: AVAssetExportPresetMediumQuality,  completion: { (outputURL, error) in
            if (outputURL != nil) {
                do {
                    let videoData = try Data(contentsOf: outputURL!)
                    self.shareToTwitter(image: mergedImage, data: videoData)
                    //                    if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
                    //                        let composer = TWTRComposerViewController.init(initialText: "Great App!", image: mergedImage, videoData: videoData)
                    //                        self.present(composer, animated: true, completion: nil)
                    //                    } else {
                    //                        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                    //                            if (session != nil) {
                    //                                let composer = TWTRComposerViewController.init(initialText: "Great App!", image: mergedImage, videoData: videoData)
                    //                                self.present(composer, animated: true, completion: nil)
                    //                            }
                    //                        })
                    //                    }
                    //                    SWShareService.sharedInstance.fromViewController = self
                    //                    let result = SWShareService.sharedInstance.shareByTwitter(shareData: videoData) { (success: Bool) in
                    //                        if success == true {
                    //                            SWUtilities.showAlertView("Success", message: "Twitter video upload completed.", fromController: self)
                    //                        } else {
                    //                            SWUtilities.showAlertView("Error", message: "Twitter video upload failed. Please try again.", fromController: self)
                    //                        }
                    //                    }
                    //                    if result == false {
                    //                        SWUtilities.showAlertView("Error", message: "No Twitter account. Please add twitter account to Settings app.", fromController: self)
                    //                    }
                } catch {
                    
                }
                
            } else {
                
            }
            
        })
    }
    
    func shareToOthers(feed: ABFeed) {
        let url = URL(string: (feed.bitImage?.url!)!)
        let data = try? Data(contentsOf: url!)
        VideoCreator.sharedInstance.createMovieWithSingleImageAndMusic(image: self.addWatermarkImage(image:UIImage(data: data!)!), audioFileURL: FileManager.sharedInstance.audioFileURL(feed.objectId!)!, assetExportPresetQuality: AVAssetExportPreset1920x1080,  completion: { (outputURL, error) in
            if (outputURL != nil) {
                do {
                    let videoData = try Data(contentsOf: outputURL!)
                    SWShareService.sharedInstance.fromViewController = self
                    SWShareService.sharedInstance.shareTo(shareData: videoData, fileURL: outputURL)
                } catch {
                    SWUtilities.showAlertView("Error", message: "Share video failed. Please try again.", fromController: self)
                }
                
            } else {
                
            }
            
        })
    }
    
    func showFeedBackVC(_ feed: ABFeed? = nil, user: ABUser? = nil) {
        //trackScreen(GASNFeedBack)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = sb.instantiateViewController(withIdentifier: "FeedbackVC_ID") as! FeedbackVC
        feedbackViewController.feedbackType = ABFeedbackType.ReportAbuse
        if user != nil { feedbackViewController.userFlagged = user  }
        if feed != nil { feedbackViewController.feedFlagged = feed  }
        feedbackViewController.isReportAbuse = true
        feedbackViewController.feedBackmail = SharedManager.sharedInstance.reportAbuseMail
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
}
extension ProfileVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTheAudioPlayer()
    }
}


extension ProfileVC : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if ((user?.isPrivate) != nil) {
        //            return 0
        //        } else {
        return feedsArray.count
        //        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTVCellIdentifier", for: indexPath) as! FeedsTVCell
        updateTheCell(cell, indexPath: indexPath)
        return cell
    }
    
    func updateTheCell(_ cell: FeedsTVCell, indexPath: IndexPath) {
        cell.delegate = self
        cell.indexpath = indexPath
        let feed = feedsArray[indexPath.row]
        
        if currentPlayingIndex == indexPath.row {
            cell.playImageView.image = UIImage(named: "pause")
        } else {
            cell.playImageView.image = UIImage(named: "play")
        }
        
        cell.nameLabel.text =  feed.postedBy?.bitUserName?.chopPrefix() ?? "Guest"
        
        //        if let username = feed.postedBy?.fullName {
        //            if username.characters.count > 2{
        //                cell.nameLabel.text = feed.postedBy?.fullName ?? "Guest"
        //            }
        //        }
        
        cell.likeImageView.image = UIImage(named: "love_empty")
        if feed.isLikedByMe {
            cell.likeImageView.image = UIImage(named: "love")
        }
        cell.descriptionLabel.text = feed.bitDescription ?? ""
        cell.durationLabel.text = feed.bitDuration ?? ""
        cell.tittlelabel.text = feed.bitTitle ?? ""
        cell.descriptionLabel.text = feed.bitDescription ?? ""
        cell.timeLabel.text = feed.createdAt?.timeAgoSimple
        cell.likeCountLabel.text = String(feed.likes!)
        cell.PlayCountLabel.text = String(feed.plays!)
        cell.commentCountLabel.text = String(feed.comments!)
        
        if let url = feed.postedBy?.profilePic?.url {
            cell.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "profile_placeholder"))
        } else {
            setTextOnImageView(imageView: cell.profileImageView, user: feed.postedBy, fromSideMenu: false)
        }
        cell.bitImageView.sd_setImage(with: URL(string:feed.bitImage?.url ?? "" ), placeholderImage: UIImage(named: "bit_placeholder"))
        
        // Disabling like image for current user's bitt.
        if feed.postedBy?.objectId == PFUser.current()?.objectId {
            cell.likeImageView.alpha = 0.3
        } else {
            cell.likeImageView.alpha = 1
        }
        
        handleNavigationAbility(cell, feed: feed)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFetchInQueue{ // wait for before fetch call complete
            nextpage = feedsArray.count - 3
            if indexPath.row == nextpage {
                currentPage += 1
                nextpage = feedsArray.count - 3
                if !stopGetingFeeds {
                    perform(#selector(ProfileVC.fetchFeeds), with: nil, afterDelay: 0.3)
                }
            }
        }
    }
    
}

//MARK: UITableViewDelegate
extension ProfileVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let feed = feedsArray[indexPath.row]
        let item = feed.bitDescription ?? ""
        let widthOfLabel = Double(view.frame.size.width) - 40
        let textHeight = item.sizeOfString(UIFont.museoSans500FontOfSize(14), constrainedToWidth: widthOfLabel)
        return (340 + textHeight.height)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if profileHeaderContainer == nil {
            profileHeaderContainer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
            profileHeaderVCInstance = storyboard?.instantiateViewController(withIdentifier: "ProfileHeaderVC_ID") as? ProfileHeaderVC
            profileHeaderVCInstance?.delegate = self
            configureChildViewController(profileHeaderVCInstance!, onView: profileHeaderContainer)
        }
        profileHeaderContainer?.clipsToBounds = true
        return profileHeaderContainer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK:- UIScrollView Delegates

extension ProfileVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffsetY = scrollView.contentOffset.y
        if scrollOffsetY > 130 {
            scrollView.contentInset = UIEdgeInsetsMake(64, 0.0, 0.0, 0.0)
            self.topView.isHidden = false
            profileNameLabelOnTop.isHidden = false
            profileNameLabel.isHidden = true
        } else {
            scrollView.contentInset = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0)
            self.topView.isHidden = true
            profileNameLabelOnTop.isHidden = true
            profileNameLabel.isHidden = false
        }
        
        makeParallaxEffect()
    }
    
    func makeParallaxEffect() {
        let offsetY = feedsTableView.contentOffset.y
        for cell in feedsTableView.visibleCells as! [FeedsTVCell] {
            let x = cell.bitImageView.frame.origin.x
            let w = cell.bitImageView.bounds.width
            let h = cell.bitImageView.bounds.height
            let y = (((offsetY - cell.frame.origin.y) / h ) * 10 )
            cell.bitImageView.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
}

extension ABFollowButtonDelegate {
    
}
