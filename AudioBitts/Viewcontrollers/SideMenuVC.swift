//
//  ViewController.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import Parse


class SideMenuVC: UIViewController {
    
    @IBOutlet weak var menuListTableView: UITableView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var pleaseWait = false
    var menuItemsInfoArray = [ABMenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().frontViewShadowRadius = 20.0
        menuItemsInfoArray = [ABMenuItem(title: "Explore", iconName: "explore", storyBoardID: "ExploreVC_ID"),
            ABMenuItem(title: "My Bitts", iconName: "mybitts", storyBoardID: "ProfileVC_ID"),
            ABMenuItem(title: "Notifications", iconName: "notification", storyBoardID: "NotificationsVC_ID"),
            ABMenuItem(title: "Rate us", iconName: "star", storyBoardID: "RateUsVC_ID"),
            ABMenuItem(title: "Tell a friend", iconName: "rateus", storyBoardID: "TellAFriendVC_ID"),
        ]
        menuListTableView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width/2
        profilePicImageView.layer.masksToBounds = true
        profilePicImageView.layer.borderColor = UIColor(red: 230, green: 31, blue: 87).cgColor
        profilePicImageView.layer.borderWidth = 2.0
        tableViewHeight.constant =  CGFloat(menuItemsInfoArray.count * 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        checkUser()
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = false
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        startListeningToUserActivityNotifications(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = true
        stopListeningToUserActivityNotifications(self)
    }
    
    func checkUser() {
        if (PFUser.current() != nil ) {
            userNameLabel.text =  PFUser.current()!["bitUsername"] as? String ?? "Welcome"
            if let username = PFUser.current()!["bitUsername"] as? String {
                if username.characters.count > 2 {
                    userNameLabel.text = username.chopPrefix() as String
                }
            }
            setProfilePic(on: profilePicImageView, user: ABUser(pfUser: PFUser.current()!), fromSideMenu: true)
            //            if let profilePic = PFUser.currentUser()!["profilePic"] as? PFFile {
            //                profilePic.getDataInBackgroundWithBlock({ (data, error) -> Void in
            //                    if let imageData = data {
            //                        self.profilePicImageView.image = UIImage(data: imageData)
            //                    }
            //                })
            //            }
            for obj in menuItemsInfoArray {
                if (obj.storyBoardID == "SignUpVC_ID") {
                    menuItemsInfoArray.remove(at: menuItemsInfoArray.count - 1)
                }
            }
        } else {
            userNameLabel.text = "Hi Guest!!"
            self.profilePicImageView.image = UIImage(named: "profile_placeholder")
            for obj in menuItemsInfoArray {
                if (obj.storyBoardID == "SignUpVC_ID") {
                    menuItemsInfoArray.remove(at: menuItemsInfoArray.count - 1)
                }
            }
            menuItemsInfoArray.append( ABMenuItem(title: "Signup", iconName: "signup", storyBoardID: "SignUpVC_ID"))
        }
        menuListTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ShowProfileButtonClick(_ sender: AnyObject) {
        if (PFUser.current() != nil) {
            //trackScreen(GASNProfile)
            showViewWithStoryBoardID("ProfileVC_ID")
        } else {
            //trackScreen(GASNSignUp)
            showViewWithStoryBoardID("SignUpVC_ID")
        }
    }
    
    @IBAction func settingButtonClick(_ sender: AnyObject) {
        if (PFUser.current() != nil) {
            //trackScreen(GASNSettings)
            showViewWithStoryBoardID("SettingsVC_ID")
        } else {
            //trackScreen(GASNSignUp)
            showViewWithStoryBoardID("SignUpVC_ID")
        }
    }
    
    func showViewWithStoryBoardID(_ storyBoardID: String) {
        if pleaseWait == true {
            return
        }
        pleaseWait = true
        if let _ = self.revealViewController() {
            if let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: storyBoardID) {
                let navController = UINavigationController(rootViewController: secondViewController)
                secondViewController.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                self.revealViewController().pushFrontViewController(navController, animated:true)
                self.perform(#selector(SideMenuVC.makeWaitFalse), with: nil, afterDelay: 1)
            }
        }
    }
    
    func makeWaitFalse() {
        pleaseWait = false
    }
    
    // MARK:- User Activity Notifications
    
    func foundModificationsInUserActivityNotifications() {
        menuListTableView.reloadData()
    }
    //
}

extension SideMenuVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTVCellIdentifier", for: indexPath) as! MenuTVCell
        cell.nameLabel.text = menuItemsInfoArray[indexPath.row].title
        cell.iconimageView.image = UIImage(named:menuItemsInfoArray[indexPath.row].iconName)
        cell.countLabel.isHidden = true
        if ("Notifications" == menuItemsInfoArray[indexPath.row].title) {
            if SharedManager.sharedInstance.notificationCount > 0 {
                cell.countLabel.isHidden = false
                cell.countLabel.layer.masksToBounds = true
                cell.countLabel.layer.cornerRadius = 10.0
                cell.countLabel.text = "\(SharedManager.sharedInstance.notificationCount)"
                cell.countLabel.updateWidthAsPerNotificationCount()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (menuItemsInfoArray[indexPath.row].storyBoardID == "ProfileVC_ID") {
            if (PFUser.current() != nil) {
                //trackScreen(GASNProfile)
                showViewWithStoryBoardID("ProfileVC_ID")
            } else {
                //trackScreen(GASNSignUp)
                showViewWithStoryBoardID("SignUpVC_ID")
            }
        } else if (menuItemsInfoArray[indexPath.row].storyBoardID == "NotificationsVC_ID") {
            if (PFUser.current() != nil) {
                //trackScreen(GASNPushNotifications)
                showViewWithStoryBoardID("NotificationsVC_ID")
            } else {
                //trackScreen(GASNSignUp)
                showViewWithStoryBoardID("SignUpVC_ID")
            }
        } else if (menuItemsInfoArray[indexPath.row].storyBoardID == "RateUsVC_ID") {
            //trackScreen(GASNRateUs)
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1072631939")!)
        } else if (menuItemsInfoArray[indexPath.row].storyBoardID == "TellAFriendVC_ID") {
            let textToShare = "Get the AudioBitts app on the Apple App Store."
            //trackScreen(GASNTellaFriend)
            if let myWebsite = URL(string: "https://itunes.apple.com/app/id1072631939") {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        } else {
            showViewWithStoryBoardID(menuItemsInfoArray[indexPath.row].storyBoardID)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

