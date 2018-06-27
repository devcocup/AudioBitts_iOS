//
//  ExploreVC.swift
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
import GoogleMobileAds

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

protocol ExploreVCDelegate: class {
    func searchHashtags()
}


class ExploreVC: BaseMainVC, GADInterstitialDelegate {
    
    @IBOutlet weak var feedsTableView: UITableView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var globalBottomLine: UIImageView!
    @IBOutlet weak var globalButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followingBottomLine: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordBottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    
    var feedsArray  : [ABFeed] = []
    var filteredFeedsArray = [ABFeed]()
    var globalfeedsArray  : [ABFeed] = []
    var followersfeedsArray  : [ABFeed] = []
    var isShowingGlobalFeeds :Bool = true // is Currently showing Global Feeds
    var isFetchInQueue :Bool = false  // wait for before fetch call complete
    var stopGetingFeeds :Bool = false // when Geting feeds count is 0 stop auto fech feeds
    var isLikeInQueue :Bool = false // checking for wait for Call back
    var duration: TimeInterval!
    var currentPage = 0
    var nextpage = 0
    var audioPlayer: AVAudioPlayer!
    var currentPlayingIndex: Int?
    var pleaseWait = false
    var lastOffsetY : CGFloat = 0
    var isFiltered : Bool!
    var searchBar :UISearchBar!
    var recordVC: RecordVC!
    var refreshControl:UIRefreshControl!
    var user: ABUser!
    weak var delegate: ExploreVCDelegate?
    var interstitial: GADInterstitial!
    
    var hashtag: String!
    
    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        self.title = "AudioBitts"
        
        // getNotificationsCount
        HeyParse.sharedInstance.getUserNotificationsCount()
        
        isFiltered = false
        feedsTableView.register(UINib(nibName: "FeedsTVCell", bundle: nil), forCellReuseIdentifier: "FeedsTVCellIdentifier")
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let firstString = NSMutableAttributedString()
        firstString.append(NSAttributedString(string:  "Refreshing....",
                                              attributes: [NSForegroundColorAttributeName: UIColor.navBarStartColor(), NSFontAttributeName: UIFont.museoSans300FontOfSize(12)]))
        // refreshControl.attributedTitle = firstString
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.navBarStartColor()
        refreshControl.addTarget(self, action: #selector(ExploreVC.refresh(_:)), for: UIControlEvents.valueChanged)
        self.feedsTableView.addSubview(refreshControl)
        
        if let user = PFUser.current() {
            if let _ = user["bitUsername"] as? String {
                
            } else {
                showBitNameView()
                return;
            }
        }
        
        setUpView()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1702501497314185/3087475803")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        
        if SharedManager.sharedInstance.isCreateBittAutomatic {
            SharedManager.sharedInstance.isCreateBittAutomatic = false
            perform(#selector(ExploreVC.recordButtonAction(_:)), with: nil, afterDelay: 1)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isFetchInQueue {
            currentPage = 0
            fetchFeeds()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTheAudioPlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- ADS Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    // MARK:- UI Updates
    func addRightBarButton(_ buttonName : String,butonAction : String) {
        let search =  UIImage(named: buttonName) as UIImage!
        let searchButton = UIButton(type: UIButtonType.custom)
        searchButton.frame = CGRect(x: 0, y: 0 , width: 30, height: 30)
        searchButton.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        searchButton.setImage(search, for: UIControlState())
        searchButton.addTarget(self, action: Selector(butonAction), for: UIControlEvents.touchUpInside)
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: searchButton)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
    }
    
    func refresh(_ sender:AnyObject) {
        currentPage = 0
        self.refreshControl.endRefreshing()
        fetchFeeds()
        
    }
    
    func setUpView() {
        followingBottomLine.isHidden = true
        globalButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        followingButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
        
        if let _ = PFUser.current(){ } else {
            tableViewTop.constant = 0
            segmentView.isHidden = true
        }
        addRightBarButton("search", butonAction: "searchButtonAction")
        fetchFeeds()
    }
    
    func showSearchView() {
        addRightBarButton("Cancel", butonAction: "cancelSearchAction")
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    // MARK:- Fetch data
    func fetchFeeds() {
        //        showIndicator()
        let userId :String = PFUser.current()?.objectId ?? ""
        isFetchInQueue = true
        HeyParse.sharedInstance.getFeedsForUser(userId, pageNo: currentPage,isGlobalFeeds:isShowingGlobalFeeds) { (success, feeds) -> Void in
            print(success)
            self.isFetchInQueue = false
            //            self.hideIndicator()
            if success {
                if self.currentPage == 0 {
                    self.feedsArray.removeAll()
                    self.globalfeedsArray.removeAll()
                    self.followersfeedsArray.removeAll()
                }
                if (feeds.count == 0) {
                    self.stopGetingFeeds = true
                }
                if self.isShowingGlobalFeeds {
                    self.globalfeedsArray.append(contentsOf: feeds)
                    self.globalfeedsArray.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
                } else {
                    self.followersfeedsArray.append(contentsOf: feeds)
                    self.followersfeedsArray.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedDescending })
                }
            }
            if self.isShowingGlobalFeeds {
                self.feedsArray = self.globalfeedsArray
            } else {
                self.feedsArray = self.followersfeedsArray
            }
            self.feedsTableView.reloadData()
        }
    }
    
    // MARK:- View Navigation
    func showSignUpVC() {
        let signupVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "SignUpVC_ID"))
        //signupVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(signupVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
    
    func showBitNameView() {
        let createAccountVCInstance = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC_ID") as! CreateAccountVC
        createAccountVCInstance.navigationSource = AccountEditNavigationSource.home
        let navController = UINavigationController(rootViewController: createAccountVCInstance)
        self.revealViewController().pushFrontViewController(navController, animated:true)
    }
    
    // MARK:- NSNotification
    func sharingDone(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sharingStatus"), object: nil)
        let status = notification.userInfo!["succeeded"] as! Bool
        if status {
            
        }
        recordVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Button Actions
    func searchButtonAction() {
        if (PFUser.current() != nil) {
            //trackScreen(GASNSearch)
            let searchViewController = storyboard?.instantiateViewController(withIdentifier: "SearchVC_ID") as! SearchVC
            navigationController?.pushViewController(searchViewController, animated: true)
        
        } else {
            showSignUpVC()
        }
    }
    
    func cancelSearchAction() {
        isFiltered = false
        feedsTableView.reloadData()
        self.navigationItem.titleView?.isHidden = true
        searchBar.resignFirstResponder()
        addRightBarButton("search", butonAction: "searchButtonAction")
        
    }
    
    @IBAction func globalButtonClicked(_ sender: UIButton) {
        if !isFetchInQueue {
            stopTheAudioPlayer()
            isShowingGlobalFeeds = true
            currentPage = 0
            stopGetingFeeds = false
            fetchFeeds()
            followingBottomLine.isHidden = true
            globalBottomLine.isHidden = false
            globalButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
            followingButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
        }
    }
    
    @IBAction func followingButtonClicked(_ sender: UIButton) {
        if !isFetchInQueue {
            stopTheAudioPlayer()
            isShowingGlobalFeeds = false
            stopGetingFeeds = false
            currentPage = 0
            fetchFeeds()
            followingBottomLine.isHidden = false
            globalBottomLine.isHidden = true
            globalButton.titleLabel?.font = UIFont.museoSans300FontOfSize(12)
            followingButton.titleLabel?.font = UIFont.museoSans500FontOfSize(12)
        }
    }
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if PFUser.current() != nil {
            SharedManager.sharedInstance.canShowLikePopUp = false
            
            // Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(ExploreVC.sharingDone(_:)), name: NSNotification.Name(rawValue: "sharingStatus"), object: nil)
            
            recordVC = storyboard?.instantiateViewController(withIdentifier: "RecordVC_ID") as! RecordVC
            present(recordVC, animated: true, completion: nil)
        } else {
            //showAlert("Login required!", message: "Please login to create a AudioBitt", on: self)
            showSignUpVC()
        }
    }
    // MARK:- Player functions
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
            HeyParse.sharedInstance.updatePlayCount(feedId, completionHandler: { (success ,feed) -> Void in
                if success {
                    self.feedsArray[self.currentPlayingIndex!] = feed!
                    self.reloadCell(self.currentPlayingIndex!)
                    
                }
            })
        }
        // reload current cell
        reloadCell(currentPlayingIndex!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            duration = audioPlayer.duration
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
    
    //    func heighlightLikeButton() {
    //        if !SharedManager.sharedInstance.canShowLikePopUp {
    //            return
    //        }
    //
    //        if let cell = feedsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? FeedsTVCell {
    //            cell.likeButton.backgroundColor = UIColor.blackColor()
    //            cell.likeButton.titleLabel?.textColor = UIColor.whiteColor()
    //            cell.likeButton.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).CGColor
    //            cell.likeButton.layer.borderWidth = 1.0
    //
    //            let startPoint = feedsTableView.convertPoint(CGPointMake(self.view.frame.width - 60, 330), toCoordinateSpace: self.view)
    //            let aView = UIView(frame: CGRect(x: 0, y: 0, width: 260, height: 40))
    //
    //            let imageView = UIImageView(frame: CGRectMake(0, 0, aView.frame.size.width, 40))
    //            imageView.image = gradientBackgroundImage(CGRectMake(0, 0, aView.frame.size.width, 40))
    //            aView.addSubview(imageView)
    //
    //            let label = UILabel(frame: CGRectMake(10, 0, aView.frame.size.width-20, 40))
    //            label.text = "Tap to like, or long hold for reactions."
    //            label.textAlignment = NSTextAlignment.Center
    //            label.textColor = UIColor.whiteColor()
    //            label.font = UIFont.museoSanRegularFontOfSize(13)
    //            aView.addSubview(label)
    //            let options = [
    //                .Type(.Up),
    //                ] as [PopoverOption]
    //            let popover = Popover(options: options, showHandler: nil) { () -> () in
    //                cell.likeButton.backgroundColor = UIColor.clearColor()
    //                cell.likeButton.titleLabel?.textColor = UIColor.blackColor()
    //                cell.likeButton.layer.borderColor = UIColor.clearColor().CGColor
    //                cell.likeButton.layer.borderWidth = 0
    //            }
    //            popover.show(aView, point: startPoint)
    //
    //            SharedManager.sharedInstance.canShowLikePopUp = false
    //        }
    //    }
    
    func featchFeedAtIndex(_ indexPath: IndexPath) {
        let feed = feedsArray[indexPath.row]
        HeyParse.sharedInstance.updateFeed(feed) { (feed) -> Void in
            self.feedsArray[indexPath.row] = feed
        }
    }
    
}


// MARK:- FeedsCellDelegate

extension ExploreVC: FeedsCellDelegate {
    
    func searchHashtags(string: String){
        let searchb = searchBar
        searchButtonAction()
        //searchBar(searchb!, textDidChange: string)
        //searchBarSearchButtonClicked(searchb!)
        
    }
    
    func likeButtonClicked(_ indexPath: IndexPath) {
        let currentfeed = feedsArray[indexPath.row]
        if let userId = PFUser.current()?.objectId {
            if let feedUserID = currentfeed.postedBy?.objectId {
                if  (feedUserID != userId) {
                    //self.trackEvent(GASNHome, action: GAEVLike, label: currentfeed.bitTitle!, value: nil)
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
                                //send push notification only when likes
                                if currentfeed.isLikedByMe {
                                    HeyParse.sharedInstance.likesPush(currentfeed)
                                }
                            }
                        })
                    }
                    
                } else {
                    //                    showAlert("", message: "You can't like your own AudioBitts", on: self)
                }
            }
        } else {
            // showAlert("Hi Guest!!", message: "Please login to like", on: self)
            showSignUpVC()
        }
    }
    
    func commentButtonClicked(_ indexPath: IndexPath) {
        //trackScreen(GASNComment)
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC_ID") as! CommentVC
        commentVC.bit = feedsArray[indexPath.row]
        commentVC.index = indexPath.row
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func playButtonClicked(_ indexPath: IndexPath) {
        let feed = feedsArray[indexPath.row]
        //self.trackEvent(GASNHome, action: GAEVPlay, label: feed.bitTitle!, value: nil)
        
        if let path = FileManager.sharedInstance.checkIfExists(feed.objectId!){
            playUsingAudioPlayer(indexPath.row, path: path)
        } else {
            setDownloadingStatusFor(indexPath)
            feed.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
                if let audioData = data {
                    if let path = FileManager.sharedInstance.saveFile(feed.objectId!, data: audioData) {
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
            
//            vc.addAction(VKAction(title: "Share to Twitter", image: UIImage(named: "share"), color: UIColor.white, cancelTitle: "") {
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
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewController(animated: true)
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
                composer.delegate = self
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async(execute: {
                TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                    if (session != nil) {
                        let composer = TWTRComposerViewController.init(initialText: "Great App!", image: image, videoData: data)
                        composer.delegate = self
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
    
    func profilePicButtonClicked(_ IndexPath: Foundation.IndexPath) {
        //trackScreen(GASNProfile)
        let feed = feedsArray[IndexPath.row]
        if let currentuserID = PFUser.current()?.objectId {
            if let feedUser = feed.postedBy {
                let profileVCInstance = storyboard?.instantiateViewController(withIdentifier: "ProfileVC_ID") as! ProfileVC
                profileVCInstance.profileNavigationSource = ProfileVCNavigationSource.exploreVC
                if currentuserID == feedUser.objectId {
                    profileVCInstance.isFollow = false
                } else {
                    profileVCInstance.isFollow = true
                }
                profileVCInstance.userInformation = feedUser
                navigationController?.pushViewController(profileVCInstance, animated: true)
            }
        } else {
            //showAlert("Hi Guest !!", message: "Please login to see profile.", on: self)
            showSignUpVC()
        }
    }
    
    func makeWaitFalse() {
        pleaseWait = false
    }
    
    func showFeedBackVC(_ feed: ABFeed) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        //trackScreen(GASNFeedBack)
        let feedbackViewController = sb.instantiateViewController(withIdentifier: "FeedbackVC_ID") as! FeedbackVC
        feedbackViewController.feedbackType = ABFeedbackType.ReportAbuse
        feedbackViewController.feedFlagged = feed
        feedbackViewController.isReportAbuse = true
        feedbackViewController.feedBackmail = SharedManager.sharedInstance.reportAbuseMail
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
}
extension ExploreVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTheAudioPlayer()
    }
}

// MARK: UITableViewDataSource
extension ExploreVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltered == false) {
            return feedsArray.count
        } else {
            return filteredFeedsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTVCellIdentifier", for: indexPath) as! FeedsTVCell
        updateTheCell(cell, indexPath: indexPath)
        return cell
    }
    
    func updateTheCell(_ cell: FeedsTVCell, indexPath: IndexPath) {
        cell.delegate = self
        cell.indexpath = indexPath
        let feed : ABFeed
        if (isFiltered == false) {
            feed = feedsArray[indexPath.row]
        } else {
            feed = filteredFeedsArray[indexPath.row]
        }
        
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
        cell.tittlelabel.text = feed.bitTitle ?? ""
        cell.durationLabel.text = feed.bitDuration ?? ""
        cell.timeLabel.text = feed.createdAt?.timeAgoSimple
        cell.descriptionLabel.text = feed.bitDescription ?? ""
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
        if !isFetchInQueue {
            nextpage = feedsArray.count - 3
            if indexPath.row == nextpage {
                currentPage += 1
                nextpage = feedsArray.count - 3
                if !stopGetingFeeds {
                    self.perform(#selector(ExploreVC.fetchFeeds), with: nil, afterDelay: 0.3)
                }
            }
        }
    }
}

// MARK:- UITableViewDelegate
extension ExploreVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let feed : ABFeed
        if (isFiltered == false) {
            feed = feedsArray[indexPath.row]
        } else {
            feed = filteredFeedsArray[indexPath.row]
        }
        let item =  feed.bitDescription ?? ""
        let widthOfLabel = Double(view.frame.size.width) - 40
        let textHeight = item.sizeOfString(UIFont.museoSans500FontOfSize(14), constrainedToWidth: widthOfLabel)
        return (340 + textHeight.height)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredFeedsArray = feedsArray.filter({( feed : ABFeed) -> Bool in
            return  feed.bitTitle!.lowercased().contains(searchText.lowercased())
        })
        print(filteredFeedsArray)
        feedsTableView.reloadData()
    }
}

// MARK:- UIScrollView Delegates

extension ExploreVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = feedsTableView.contentOffset.y
        for cell in feedsTableView.visibleCells as! [FeedsTVCell] {
            let x = cell.bitImageView.frame.origin.x
            let w = cell.bitImageView.bounds.width
            let h = cell.bitImageView.bounds.height
            let y = (((offsetY - cell.frame.origin.y) / h ) * 10 )
            cell.bitImageView.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.view.layoutIfNeeded()
        if scrollView.contentOffset.y > lastOffsetY {
            if self.recordButton.isHidden == false {
                self.recordBottom.constant = 75
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    self.recordButton.isHidden = true
                })
            }
        } else {
            if self.recordButton.isHidden == true {
                self.recordButton.isHidden = false
                self.recordBottom.constant = -10
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    
                }, completion: { (completed) -> Void in
                    
                })
            }
        }
    }
}


// MARK: - UISearchBar Delegate
extension ExploreVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar : UISearchBar) {
        print("test")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            isFiltered = false
        } else {
            isFiltered =  true
            filterContentForSearchText(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ExploreVC: TWTRComposerViewControllerDelegate {
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        controller.dismiss(animated: true, completion: nil)
    }
}
