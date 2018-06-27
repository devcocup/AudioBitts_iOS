//
//  Settings.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import Parse

class SettingsVC: BaseMainVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var settingsTableView: UITableView!
    
    var user: ABUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        configureRightBarButton()
        
        user = ABUser(pfUser: PFUser.current()!)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Sign Out")
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        ABUserManager.sharedInstance.logOut()
        self.rightButton.isHidden = true
        showExploreVC()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingsTVCell
        cell.lineView.isHidden = true
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.titleLabel.text = "Push Notifications"
                cell.lineView.isHidden = false
            } else {
                cell.titleLabel.text = "Profile"
            }
        }
        
        if indexPath.section == 1 {
            cell.titleLabel.text = "Report a problem"
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.titleLabel.text = "Privacy Policy"
                cell.lineView.isHidden = false
            } else if indexPath.row == 1 {
                cell.titleLabel.text = "Terms and Conditions"
                cell.lineView.isHidden = false
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "Attribution"
            } else {
                let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as! SettingsFooterTVCell
                footerCell.backgroundColor = UIColor.abGrayColor()
                return footerCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SETTINGS"
        } else if section == 1 {
            return "SUPPORT"
        } else {
            return "ABOUT"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel: UILabel = UILabel()
        myLabel.frame = CGRect(x: 20, y: 23, width: 320, height: 20)
        myLabel.font = UIFont.museoSans700FontOfSize(12)
        myLabel.textColor = UIColor(red: 129, green: 129, blue: 129)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        let headerView: UIView = UIView()
        headerView.backgroundColor = UIColor.abGrayColor()
        headerView.addSubview(myLabel)
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                showPushNotificationVC()
            } else {
                showEditProfileVC()
            }
        }
        
        if indexPath.section == 1 {
            let vc = VKActionController()
            if (PFUser.current() != nil) {
                vc.addAction(VKAction(title: "General Feedback", image: UIImage(named: "feedback"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                    in
                    //self.trackScreen(GASNFeedBack)
                    self.showFeedBackVC()
                    })
                vc.addAction(VKAction(title: "Something isn’t working", image: UIImage(named: "notWorking"), color: UIColor.white, cancelTitle: "") { (action) -> Void
                    in
                    //self.trackScreen(GASNFeedBack)
                    self.showNotWorkingVC()
                    })
                
                vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
                    
                    })
                present(vc, animated: true, completion: nil)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                showPrivacyVC(PrivacyContentType.privacyPolicy)
            } else if indexPath.row == 1 {
                showPrivacyVC(PrivacyContentType.termsOfUse)
            } else {
                showAttributionVC()
            }
        }
    }
    func showAttributionVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let attributionVC = sb.instantiateViewController(withIdentifier: "AttributionVC_ID") as! AttributionVC
        self.navigationController?.pushViewController(attributionVC, animated: true)
    }
    
    func showEditProfileVC() {
        let profileVCInstance = storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC_ID") as! CreateAccountVC
        profileVCInstance.user = user
        profileVCInstance.navigationSource = AccountEditNavigationSource.profile
        navigationController?.pushViewController(profileVCInstance, animated: true)
    }
    
    func showPushNotificationVC() {
        //trackScreen(GASNPushNotificationsSetting)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let pusherViewController = sb.instantiateViewController(withIdentifier: "PushNotificationVC_ID") as! PushNotificationVC
        pusherViewController.title = "PushNotifications"
        self.navigationController?.pushViewController(pusherViewController, animated: true)
    }
    
    func showFeedBackVC() {
        //trackScreen(GASNFeedBack)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = sb.instantiateViewController(withIdentifier: "FeedbackVC_ID") as! FeedbackVC
        feedbackViewController.feedbackType = ABFeedbackType.GeneralFeedback
        feedbackViewController.isReportAbuse = false
        feedbackViewController.feedBackmail = SharedManager.sharedInstance.feedbackEmail
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
    func showNotWorkingVC() {
        //trackScreen(GASNFeedBack)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let feedbackViewController = sb.instantiateViewController(withIdentifier: "FeedbackVC_ID") as! FeedbackVC
        feedbackViewController.feedbackType = ABFeedbackType.SomethingIsntWorking
        feedbackViewController.isReportAbuse = true
        feedbackViewController.feedBackmail = SharedManager.sharedInstance.errorReportMail
        self.navigationController?.pushViewController(feedbackViewController, animated: true)
    }
    
    func showPrivacyVC(_ contentType: PrivacyContentType) {
        let privacyVCInstance = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC_ID") as! PrivacyPolicyVC
        privacyVCInstance.contentType = contentType
        self.navigationController?.pushViewController(privacyVCInstance, animated: true)
    }
    
    func showExploreVC() {
        //trackScreen(GASNHome)
        let exploreVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "ExploreVC_ID"))
        //exploreVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(exploreVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
}
