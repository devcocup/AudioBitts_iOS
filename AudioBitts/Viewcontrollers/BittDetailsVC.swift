//
//  BittDetailsVC.swift
//  AudioBitts
//
//  Created by Navya on 13/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import SDWebImage
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


class BittDetailsVC: BaseVC {
    
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet weak var bittNotAvailableMsg: UILabel!
    
    var bitt: ABFeed?
    var isFetchInQueue :Bool = false  // wait for before fetch call complete
    var bittCategory = BittsCategory.myBitts
    var currentPage = 0
    var user: ABUser?
    var feedsArray : [ABFeed] = []
    var bittsOfMe : [ABFeed] = []
    var myBitts : [ABFeed] = []
    var isbittAvailable: Bool?
    var detailNotificationArray = [ABFeed]()
    
    var likeNotification:ABFeed!
    var isNavigated = false
    
    var stopGetingFeeds :Bool = false // when Geting feeds count is 0 stop auto fech feeds
    var isLikeInQueue :Bool = false // checking for wait for Call back
    
    var currentPlayingIndex: Int?
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bitt Details"
        if bitt != nil {
            detailNotificationArray += [bitt!]
        }
        if (isbittAvailable == false) {
            feedTableView.isHidden = true
            bittNotAvailableMsg.isHidden = false
        }
        feedTableView.register(UINib(nibName: "FeedsTVCell", bundle: nil), forCellReuseIdentifier: "FeedsTVCellIdentifier")
        addBackButton()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchFeeds() {
        isFetchInQueue = true
        if bittCategory == .myBitts {
            if let  userID = PFUser.current()!.objectId {
                if let profileID = user?.objectId {
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
                            self.feedsArray = self.myBitts
                        }
                        self.feedTableView.reloadData()
                    }
                }
            }
        } else {
            if let userID = PFUser.current()!.objectId {
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
                    self.feedTableView.reloadData()
                }
            }
        }
    }
    
    func reloadCell(_ index: Int) {
        let selectedCarIndexPath = IndexPath(row: index, section: 0)
        feedTableView.reloadRows(at: [selectedCarIndexPath], with: UITableViewRowAnimation.none)
    }
    
    func setDownloadingStatusFor(_ indexPath: IndexPath) {
        if let cell = feedTableView.cellForRow(at: indexPath) as? FeedsTVCell {
            cell.playImageView.image = UIImage(named: "downloading")
        }
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
        let feed = bitt
        feed?.plays = (feed?.plays ?? 0) + 1
        if let feedId = bitt!.objectId {
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
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
extension BittDetailsVC: UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if ((user?.isPrivate) != nil) {
        //            return 0
        //        } else {
        return detailNotificationArray.count
        //        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTVCellIdentifier", for: indexPath) as! FeedsTVCell
        cell.delegate = self
        cell.indexpath = indexPath
        if let feed = detailNotificationArray.first {
            
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
        return cell
    }
    
    //    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //        if !isFetchInQueue{ // wait for before fetch call complete
    //            nextpage = feedsArray.count - 3
    //            if indexPath.row == nextpage {
    //                currentPage++
    //                nextpage = feedsArray.count - 3
    //                if !stopGetingFeeds {
    //                    performSelector("fetchFeeds", withObject: nil, afterDelay: 0.3)
    //                }
    //            }
    //        }
    //    }
    
}
extension BittDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let feed = bitt
        let item = feed?.bitDescription ?? ""
        let widthOfLabel = Double(view.frame.size.width) - 40
        let textHeight = item.sizeOfString(UIFont.museoSans500FontOfSize(14), constrainedToWidth: widthOfLabel)
        return (340 + textHeight.height)
    }
    
}

extension BittDetailsVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTheAudioPlayer()
    }
}

extension BittDetailsVC: FeedsCellDelegate {
    func searchHashtags(string: String) {
        
    }
    
    func likeButtonClicked(_ indexPath: IndexPath) {
        if let currentfeed = bitt {
            if let userId = PFUser.current()?.objectId {
                if let feedUserID = currentfeed.postedBy?.objectId {
                    if  (feedUserID != userId) {
                        //self.trackEvent(GASNProfile, action: GAEVLike, label: (currentfeed.bitTitle)!, value: nil)
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
                                    //                                    self.feedsArray[indexPath.row] = feed!
                                    //                                    self.feedsArray[indexPath.row].isLikedByMe = currentfeed.isLikedByMe
                                    self.reloadCell(indexPath.row)
                                    if currentfeed.isLikedByMe {
                                        HeyParse.sharedInstance.likesPush(currentfeed)
                                    }
                                }
                            })
                        }
                    } else {
                        //                        showAlert("", message: "You can't like your own AudioBitts", on: self)
                    }
                }
            }else{
                showAlert("Hi Guest!!", message: "Please login to like", on: self)
            }
        }
    }
    
    func commentButtonClicked(_ indexPath: IndexPath) {
        //trackScreen(GASNComment)
        let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC_ID") as! CommentVC
        commentVC.bit = bitt
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func playButtonClicked(_ indexPath: IndexPath) {
        let feed = bitt
        //self.trackEvent(GASNProfile, action: GAEVPlay, label: feed!.bitTitle!, value: nil)
        
        if let path = FileManager.sharedInstance.checkIfExists(feed!.objectId!) {
            playUsingAudioPlayer(indexPath.row, path: path)
        }
        else {
            setDownloadingStatusFor(indexPath)
            feed!.bitAudio?.getDataInBackground(block: { (data, error) -> Void in
                if let audioData = data{
                    if let path = FileManager.sharedInstance.saveFile(feed!.objectId!, data: audioData){
                        self.playUsingAudioPlayer(indexPath.row, path: path)
                    }
                }
            })
        }
    }
    
    func showExploreVC() {
        //trackScreen(GASNHome)
        let exploreVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "ExploreVC_ID"))
        //exploreVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(exploreVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
    
    func shareButtonClicked(_ indexPath: IndexPath) {
        
        let vc = VKActionController()
        
        func configureReportAbuseOption() {
            vc.addAction(VKAction(title: "Report Abuse", image: UIImage(named: "abuse"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                in
                //self.trackScreen(GASNFeedBack)
                self.showFeedBackVC(self.bitt!)
                })
            
            vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
                
                })
            present(vc, animated: true, completion: nil)
        }
        
        if (PFUser.current()?.objectId == self.bitt!.postedBy?.objectId) {
            //            vc.addAction(VKAction(title: "Edit", image: UIImage(named: "edit"), color: UIColor.whiteColor(), cancelTitle: "") { (action) -> Void
            //                in
            //                self.trackScreen(GASNFeedBack)
            //                showAlert("", message: "In Progress", on: self)
            //                })
            
            vc.addAction(VKAction(title: "Delete", image: UIImage(named: "delete"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
                
                let alert = UIAlertController(title: "", message: "Delete Bitt?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    
                    let bit = PFObject(className: "Feeds")
                    bit.objectId = self.bitt!.objectId
                    
                    bit.deleteInBackground(block: { (sucess, error) -> Void in
                        if sucess {
                            self.detailNotificationArray.removeLast()
                            self.feedTableView.reloadData()
                            
                            showAlert("Deleted", message: "", on: self)
                            self.showExploreVC()
                        } else {
                            showAlert("Error !!", message: "Try again", on: self)
                        }
                    })
                    
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                
                })
            
            
        } else {
            configureReportAbuseOption()
        }
        vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
            
            })
        
        present(vc, animated: true, completion: nil)
    }
    
    func profilePicButtonClicked(_ IndexPath: Foundation.IndexPath) {
        print("Profile Pic Button Clicked")
    }
    
    func showFeedBackVC(_ feed: ABFeed) {
        //trackScreen(GASNFeedBack)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = sb.instantiateViewController(withIdentifier: "FeedbackVC_ID") as! FeedbackVC
        feedbackViewController.feedbackType = ABFeedbackType.ReportAbuse
        feedbackViewController.feedFlagged = feed
        feedbackViewController.isReportAbuse = true
        feedbackViewController.feedBackmail = SharedManager.sharedInstance.reportAbuseMail
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
}
