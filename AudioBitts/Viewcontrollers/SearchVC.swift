//
//  SearchVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 01/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
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


class SearchVC: BaseMainVC {
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchFailView: UIView!
    
    var searchBar :UISearchBar!
    var isFiltered : Bool!
    var feedsArray = [ABFeed]()
    var filteredFeedsArray = [ABFeed]()
    var audioPlayer: AVAudioPlayer!
    var currentPlayingIndex: Int?
    var users = [ABUser]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.register(UINib(nibName: "FollowTVCell", bundle: nil), forCellReuseIdentifier: "FollowTVCell_ID")
        
        configureRightBarButton()
        showSearchView()
        //        fetchTrenigFeedsAndUsers()
        setEmptyBackButton()
        
    }
    
    func setEmptyBackButton() {
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: UIView()), animated: false)
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Cancel")
    }
    
    func showSearchView() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        searchBar.barStyle = .blackTranslucent
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Type username, title or tags"
        searchBar.delegate = self
        searchBar.setTextColor(UIColor.white)
        self.navigationItem.titleView = searchBar
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        backBtnClicked()
    }
    
    func searchButtonAction() {
        showSearchView()
    }
    
    func cancelSearchAction() {
        isFiltered = false
        self.navigationItem.titleView?.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    
    func playUsingAudioPlayer(_ index: Int, path: String) {
        if currentPlayingIndex == index {
            self.stopTheAudioPlayer()
            return;
        }
        
        if let i = currentPlayingIndex {
            currentPlayingIndex = index
            self.reloadCell(i)
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
            //audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            //duration = audioPlayer.duration
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
        if let cell = searchTableView.cellForRow(at: indexPath) as? SearchFeedTVCell {
            //cell.playImageView.image = UIImage(named: "downloading")
        }
    }
    
    func reloadCell(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = searchTableView.cellForRow(at: indexPath) as? SearchFeedTVCell {
            updateTheCell(cell, indexPath: indexPath)
        }
        
        //        let selectedCarIndexPath = NSIndexPath(forRow: index, inSection: 0)
        //        feedsTableView.reloadRowsAtIndexPaths([selectedCarIndexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func updateTheCell(_ cell: SearchFeedTVCell, indexPath: IndexPath) {
        //cell.delegate = self
        cell.indexpath = indexPath
        let feed : ABFeed
        if (isFiltered == false) {
            feed = feedsArray[indexPath.row]
        } else {
            feed = filteredFeedsArray[indexPath.row]
        }
        
//        if currentPlayingIndex == indexPath.row {
//            cell.playImageView.image = UIImage(named: "pause")
//        } else {
//            cell.playImageView.image = UIImage(named: "play")
//        }
//        cell.nameLabel.text =  feed.postedBy?.bitUserName?.chopPrefix() ?? "Guest"
        
        //        if let username = feed.postedBy?.fullName {
        //            if username.characters.count > 2{
        //                cell.nameLabel.text = feed.postedBy?.fullName ?? "Guest"
        //            }
        //        }
//        cell.likeImageView.image = UIImage(named: "love_empty")
//        if feed.isLikedByMe {
//            cell.likeImageView.image = UIImage(named: "love")
//        }
        //cell.tittlelabel.text = feed.bitTitle ?? ""
        //cell.durationLabel.text = feed.bitDuration ?? ""
        //cell.timeLabel.text = feed.createdAt?.timeAgoSimple
        //cell.descriptionLabel.text = feed.bitDescription ?? ""
        //cell.likeCountLabel.text = String(feed.likes!)
        //cell.playCountLable.text = String(feed.plays!)
        //cell.commentCountLabel.text = String(feed.comments!)
        if let url = feed.postedBy?.profilePic?.url {
            cell.proflePicImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "profile_placeholder"))
        } else {
            setTextOnImageView(imageView: cell.proflePicImageView, user: feed.postedBy, fromSideMenu: false)
        }
        //cell.bitImageView.sd_setImage(with: URL(string:feed.bitImage?.url ?? "" ), placeholderImage: UIImage(named: "bit_placeholder"))
        
        // Disabling like image for current user's bitt.
//        if feed.postedBy?.objectId == PFUser.current()?.objectId {
//            cell.likeImageView.alpha = 0.3
//        } else {
//            cell.likeImageView.alpha = 1
//        }
//
        //handleNavigationAbility(cell, feed: feed)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    func fetchTrenigFeedsAndUsers() {
    //        showIndicator()
    //        HeyParse.sharedInstance.getTrendingFeeds { (sucess, trendingFeeds) -> Void in
    //            self.hideIndicator()
    //            if sucess {
    //                self.feedsArray.appendContentsOf(trendingFeeds)
    //                self.searchTableView.reloadData()
    //                self.searchFailView.hidden = true
    //            }
    //        }
    //    }

}


extension SearchVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if users.count == 0 && feedsArray.count == 0 {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "People"
        } else {
            return "Bitts"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 41
            
        }
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SerachSectionTVCellIdentifier") as! SerachSectionTVCell
        cell.sectionTittle.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
        cell.separatorView.isHidden = false
        if section == 0 {
            cell.separatorView.isHidden = true
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.users.count
        } else {
            return self.feedsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTVCell_ID", for: indexPath) as! FollowTVCell
            cell.userInfo = users[indexPath.row]
            //            cell.userNameLabel.textColor = UIColor.blackColor()
            //            cell.nameLabel.textColor = UIColor(red: 129 , green:129 , blue: 129)
            cell.matchToSearchUI(users[indexPath.row].numberOfFollowers)
            cell.saparatorLine.isHidden = false
            if indexPath.row == users.count-1 {
                cell.saparatorLine.isHidden = true
            }
            return cell
        } else {
            let feed = feedsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFeedTVCellIdentifier", for: indexPath) as!
            SearchFeedTVCell
            cell.indexpath = indexPath
            cell.proflePicImageView.sd_setImage(with: URL(string:feed.bitImage?.url ?? "" ), placeholderImage: UIImage(named: "bit_placeholder"))
            cell.nameLabel.text = String(feed.bitTitle!)
            //cell.nameLabel.text = feed.postedBy?.bitUserName?.chopPrefix()
            //cell.tittleLabel.text = feed.bitTitle
            cell.playCountLable.text = String(feed.plays!)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension SearchVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //trackScreen(GASNProfile)
        if (indexPath.section == 0 ) {
            let user = users[indexPath.row]
            if let currentuserID = PFUser.current()?.objectId {
                let profileVCInstance = storyboard?.instantiateViewController(withIdentifier: "ProfileVC_ID") as! ProfileVC
                profileVCInstance.profileNavigationSource = ProfileVCNavigationSource.searchVC
                if currentuserID == user.objectId {
                    profileVCInstance.isFollow = false
                } else {
                    profileVCInstance.isFollow = true
                    profileVCInstance.userInformation = user
                    navigationController?.pushViewController(profileVCInstance, animated: true)
                }
            }
            
        } else {
            let feed = feedsArray[indexPath.row]
            let bittDetailsVCInstance = storyboard?.instantiateViewController(withIdentifier: "BittDetailsVC_ID") as! BittDetailsVC
            bittDetailsVCInstance.bitt = feed
            bittDetailsVCInstance.user = feed.postedBy
            bittDetailsVCInstance.isbittAvailable = true
            navigationController?.pushViewController(bittDetailsVCInstance, animated: true)
        }
    }
}

extension SearchVC:UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar : UISearchBar) {
        print("typing...")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            isFiltered = false
        } else {
            isFiltered =  true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text?.characters.count > 1 {
            HeyParse.sharedInstance.searchFeeds(searchBar.text ?? "" , userID: PFUser.current()?.objectId ?? "", pageNo: 0) { (success, feeds, users) -> Void in
                if success {
                    self.feedsArray.removeAll()
                    self.users.removeAll()
                    self.searchFailView.isHidden = true
                    self.feedsArray.append(contentsOf: feeds)
                    self.users.append(contentsOf: users)
                    self.searchTableView.reloadData()
                } else {
                    self.searchFailView.isHidden = false
                }
            }
        }
    }
}
