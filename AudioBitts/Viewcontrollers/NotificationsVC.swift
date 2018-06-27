//
//  NotificationsVC.swift
//  AudioBitts
//
//  Created by Navya on 03/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse


enum NotificationType {
    case comment, like, followed, requested
}

class NotificationsVC: BaseMainVC {
    
    @IBOutlet var notificationsTableView: UITableView!
    var notificationsArray = [ABNotification]()
    var numberOfRequestHolderView: UIView!
    var requestedUsersArray = [ABUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notifications"
        notificationsTableView.register(UINib(nibName: "NotificationTVCell", bundle: nil), forCellReuseIdentifier: "NotificationTVCell_ID")
        
        dealWithNavigationBarUI()
        fetchdata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getRequestsInformation()
        HeyParse.sharedInstance.getUserNotificationsCount()
        
        notificationsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addMenuButton()
    }
    
    // MARK:- Requests
    
    func dealWithNavigationBarUI() {
        configureBackButton()
        dealWithNumberOfRequestsUI()
    }
    
    func dealWithNumberOfRequestsUI() {
        numberOfRequestHolderView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 44))
        //        numberOfRequestHolderView.backgroundColor = UIColor.orangeColor()
        
        // Count label
        let requestsCountLabel = UILabel()
        requestsCountLabel.frame = CGRect(x: 29, y: 7, width: 16, height: 20)
        requestsCountLabel.tag = 100
        requestsCountLabel.backgroundColor = UIColor.white
        requestsCountLabel.layer.cornerRadius = 10
        requestsCountLabel.layer.masksToBounds = true
        requestsCountLabel.textAlignment = .center
        requestsCountLabel.font = UIFont.museoSans700FontOfSize(10)
        requestsCountLabel.textColor = UIColor.navBarEndColor()
        numberOfRequestHolderView.addSubview(requestsCountLabel)
        updateRequestsInformation()
        
        // Person image
        let personImage = UIImageView(frame: CGRect(x: 48, y: 15, width: 18, height: 18))
        personImage.image = UIImage(named: "person_Request")
        numberOfRequestHolderView.addSubview(personImage)
        
        // Button to perform action
        let requestsButton = UIButton(type: UIButtonType.custom)
        requestsButton.frame = numberOfRequestHolderView.bounds
        requestsButton.addTarget(self, action: #selector(NotificationsVC.requestsBtnAction), for: UIControlEvents.touchUpInside)
        numberOfRequestHolderView.addSubview(requestsButton)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: numberOfRequestHolderView)
        self.navigationItem.setRightBarButton(leftBarButtonItem, animated: false)
        
    }
    
    func updateRequestsInformation() {
        if requestedUsersArray.count == 0 {
            numberOfRequestHolderView.isHidden = true
        } else {
            numberOfRequestHolderView.isHidden = false
            let requestsCountLabel = numberOfRequestHolderView.viewWithTag(100) as! UILabel
            requestsCountLabel.text = "\(requestedUsersArray.count)"
            requestsCountLabel.updateWidthAsPerNotificationCount()
        }
    }
    
    func requestsBtnAction() {
        let requestsVC = storyboard?.instantiateViewController(withIdentifier: "FollowingRequestsVC_ID") as! FollowingRequestsVC
        requestsVC.usersArray = requestedUsersArray
        requestsVC.notificationsArray = notificationsArray
        requestsVC.didChangeNotificationsInfo = {(notificasions: [ABNotification]) in
            self.notificationsArray = notificasions
        }
        navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    func getRequestsInformation() {
        HeyParse.sharedInstance.getRequestsInformation { (errorInformation, users) -> Void in
            if let users = users {
                self.requestedUsersArray = users
                self.updateRequestsInformation()
            } else {
                if let errorInformation = errorInformation {
                    showAlert("Error!", message: errorInformation, on: self)
                }
            }
        }
    }
    
    // MARK:-
    
    func fetchdata() {
        showIndicator()
        HeyParse.sharedInstance.getUserNotifications { (notifications, errorInformation) -> Void in
            self.hideIndicator()
            if let notifications = notifications {
                self.notificationsArray = notifications
                self.dealWithFollwedTypeNotificationsAndRefreshUI()
            } else if let errorInformation = errorInformation {
                showAlert("Error!", message: errorInformation, on: self)
            }
        }
    }
    
    func dealWithFollwedTypeNotificationsAndRefreshUI() {
        var follwedUsersArray = [ABUser]()
        var follwedNotificationsIndexesArray = [Int]()
        
        for i in 0 ..< notificationsArray.count {
            let item = notificationsArray[i]
            if item.type == .followed {
                follwedUsersArray.append(item.fromUser!)
                follwedNotificationsIndexesArray.append(i)
            }
        }
        showIndicator()
        HeyParse.sharedInstance.getCurrentUserFollowingListAndFindOutRelationWithUsers(follwedUsersArray, completionHandler: { (errorInfo) -> Void in
            self.hideIndicator()
            if errorInfo == nil {
                for i in 0 ..< follwedUsersArray.count {
                    let followedTypeNotfication = self.notificationsArray[follwedNotificationsIndexesArray[i]]
                    followedTypeNotfication.fromUser = follwedUsersArray[i]
                }
                self.notificationsTableView.reloadData()
                
            } else {
                showAlert("Error!", message: errorInfo!, on: self)
            }
        })
    }
    
    func makeSureUpdationForFollowButton(_ indexPath: IndexPath) {
        let notification = notificationsArray[indexPath.row]
        var indexPathsToRefresh = [IndexPath]()
        
        for i in 0 ..< notificationsArray.count {
            let item = notificationsArray[i]
            if item.fromUser?.objectId == notification.fromUser?.objectId &&  item.type == notification.type {
                item.fromUser?.relationWithCurrentUser = notification.fromUser!.relationWithCurrentUser
                
                let indexPathToReload = IndexPath(row: i, section: 0)
                changeReadStatus(indexPathToReload, modifyData: true, reloadCell: false, reloadReadCount: false)
                
                indexPathsToRefresh.append(indexPathToReload)
            }
        }
        
        changeReadStatus(nil, modifyData: false, reloadCell: false, reloadReadCount: true)
        
        if indexPathsToRefresh.count > 0 {
            notificationsTableView.reloadRows(at: indexPathsToRefresh, with: UITableViewRowAnimation.none)
        }
    }
    
    func changeNotificationStatus(_ indexPath: IndexPath) {
        let noti = notificationsArray[indexPath.row]
        let noticatio = PFObject(withoutDataWithClassName: "Notification", objectId: noti.objectId)
        noticatio["isRead"] = true
        noticatio.saveInBackground()
        
        notificationsArray.remove(at: indexPath.row)
        notificationsTableView.reloadData()
    }
    
    func changeReadStatus(_ indexPath: IndexPath?, modifyData: Bool = true, reloadCell: Bool = true, reloadReadCount: Bool = true) {
        if modifyData {
            let notification = notificationsArray[indexPath!.row]
            notification.isRead = true
            
            let noticationObject = PFObject(withoutDataWithClassName: "Notification", objectId: notification.objectId)
            noticationObject["isRead"] = true
            noticationObject.saveInBackground()
        }
        
        if reloadCell { notificationsTableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none) }
        if reloadReadCount { HeyParse.sharedInstance.getUserNotificationsCount() }
    }
    
    func showProfileVC(_ indexPath:IndexPath) {
        let profileVCInstance = storyboard?.instantiateViewController(withIdentifier: "ProfileVC_ID") as! ProfileVC
        profileVCInstance.profileNavigationSource = ProfileVCNavigationSource.notificationsVC
        profileVCInstance.isFollow = true
        profileVCInstance.userInformation = notificationsArray[indexPath.row].fromUser
        navigationController?.pushViewController(profileVCInstance, animated: true)
    }
    
    func showBittInformation(_ indexPath: IndexPath) {
        let bittDetailsVCInstance = storyboard?.instantiateViewController(withIdentifier: "BittDetailsVC_ID") as! BittDetailsVC
        if let bit = notificationsArray[indexPath.row].bit {
            bittDetailsVCInstance.bitt = bit
            bittDetailsVCInstance.user = notificationsArray[indexPath.row].toUser
            bittDetailsVCInstance.isbittAvailable = true
        } else {
            print("not existed")
            bittDetailsVCInstance.isbittAvailable = false
        }
        navigationController?.pushViewController(bittDetailsVCInstance, animated: true)
    }
}

extension NotificationsVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVCell_ID", for: indexPath) as! NotificationTVCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.notificationInfo = notificationsArray[indexPath.row]
        return cell
    }
}

//MARK:- Tableview delegate
extension NotificationsVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeReadStatus(indexPath)
        
        let notification = notificationsArray[indexPath.row]
        if notification.type == .comment || notification.type == .like {
            showBittInformation(indexPath)
        } else if notification.type == .followed {
            showProfileVC(indexPath)
        } else if notification.type == .requested {
            requestsBtnAction()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK:- NotificationTVCellDelegate
extension NotificationsVC : NotificationTVCellDelegate {
    func didTapOnProfilePic(_ inCell: NotificationTVCell, indexPath: IndexPath) {
        changeReadStatus(indexPath)
        showProfileVC(indexPath)
    }
    
    func didTapOnFollowButton(_ inCell: NotificationTVCell, indexPath: IndexPath) {
        // Just making sure following button is getting updated correctly for all duplicate type notifications if any.
        makeSureUpdationForFollowButton(indexPath)
    }
}

extension NotificationsVC : FollowingNotificationCellDelegate {
    func followButtonClicked(_ indexPath: IndexPath) {
        notificationsTableView.isUserInteractionEnabled = true
        changeNotificationStatus(indexPath)
    }
    
    func disableTableView() {
        notificationsTableView.isUserInteractionEnabled = false
    }
    
    func profileButtonTapped(_ indexPath: IndexPath) {
        //        changeNotificationStatus(indexPath)
        showProfileVC(indexPath)
    }
}

extension NotificationsVC : CommentNotificationTVCellDelegate {
    func commentProfileButtonTapped(_ indexPath: IndexPath) {
        changeNotificationStatus(indexPath)
        showProfileVC(indexPath)
    }
}
