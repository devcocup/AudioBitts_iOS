//
//  BaseVC.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    var indicatorView: CustomActivityIndicator?
    
    var hamburgerMenuButton: UIButton!
    var notificationsCountLabel: UILabel!
    
    var rightButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure UI
        setNavigationBarColor()
        configureBackButton()
        
        if let revealController = self.revealViewController() {
            revealController.panGestureRecognizer()
            revealController.tapGestureRecognizer()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib BaseVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        if let _ = self.navigationController{
            self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.museoSans500FontOfSize(14),NSForegroundColorAttributeName: UIColor.white]
        }
        
        startListeningToUserActivityNotifications(self)
        
        updateNotificationsCountInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToUserActivityNotifications(self)
    }
    
    func configureBackButton() {
        addBackButton()
    }
    
    func configureRightBarButton() {
        
    }
    
    //    func configureTitleView() {
    //        //addTitleAtLeft()
    //    }
    //
    //    func configureDynamicNavBar() {
    //
    ////        addBackButton()
    ////        addTitleAtLeft()
    //    }
    //
    //    func setViewTitle(titlestring: String) {
    ////        titleLabel.text = titlestring
    ////        titleLabel.hidden = false
    //    }
    
    func addBackButton() {
        let back = UIImage(named: "back") as UIImage!
        let backButton = UIButton(type: UIButtonType.custom)
        backButton.frame = CGRect(x: 0, y: 0 , width: 30, height: 30)
        backButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 7, 10)
        backButton.setImage(back, for: UIControlState())
        backButton.addTarget(self, action: #selector(BaseVC.backBtnClicked), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    //    func addBadgeToMenuBarButtonItem(countValue : String){
    //        let customButton = UIButton(type: UIButtonType.Custom)
    //        let badgeButton = BBBadgeBarButtonItem(customButton)
    //        badgeButton.badgeValue = countValue
    //        self.navigationItem.setLeftBarButtonItem(badgeButton, animated: false)
    //
    //    }
    
    func addMenuButton() {
        hamburgerMenuButton = UIButton(type: UIButtonType.custom)
        hamburgerMenuButton.frame = CGRect(x: 0, y: 0 , width: 30, height: 30)
        hamburgerMenuButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 7, 10)
        hamburgerMenuButton.setImage(UIImage(named: "menu"), for: UIControlState())
        hamburgerMenuButton.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
        hamburgerMenuButton.addTarget(self, action: #selector(BaseVC.menuBtnAction), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: hamburgerMenuButton)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        
        dealWithActivityNotificationsUI(hamburgerMenuButton)
    }
    
    func menuBtnAction() { view.endEditing(true) }
    
    func addLeftBarButton(_ title: String) {
        let leftButton = UIButton(type: UIButtonType.custom)
        leftButton.frame = CGRect(x: -15, y: 0, width: 60, height: 30)
        leftButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 7, 10)
        leftButton.setTitle(title, for: UIControlState())
        leftButton.setTitleColor(UIColor.white, for: UIControlState())
        leftButton.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        leftButton.titleLabel?.font = UIFont.museoSanRegularFontOfSize(14)
        leftButton.addTarget(self, action: #selector(BaseVC.backBtnClicked), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    
    func addRightBarButton(_ title: String) {
        rightButton = UIButton(type: UIButtonType.custom)
        rightButton.frame = CGRect(x: 0, y: 0, width: 65, height: 30)
        rightButton.contentEdgeInsets = UIEdgeInsetsMake(10, 4, 7, 2)
        rightButton.setTitle(title, for: UIControlState())
        rightButton.setTitleColor(UIColor.white, for: UIControlState())
        rightButton.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        rightButton.titleLabel?.font = UIFont.museoSanRegularFontOfSize(14)
        rightButton.addTarget(self, action: #selector(BaseVC.rightBarButtionClicked(_:)), for: UIControlEvents.touchUpInside)
        let rightButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.setRightBarButton(rightButtonItem, animated: false)
    }
    
    func rightBarButtionClicked(_ sender: UIButton) {
        print("BaseVC")
    }
    
    func setNavigationBarColor() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let fontDictionary = [ NSForegroundColorAttributeName:UIColor.white ]
        self.navigationController?.navigationBar.titleTextAttributes = fontDictionary
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }
    
    func imageLayerForGradientBackground() -> UIImage {
        let updatedFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 66)
        let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func backBtnClicked() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    // MARK:- User Activity Notifications
    
    func getConfigureNotificationCountLabel() -> UILabel {
        notificationsCountLabel = UILabel()
        notificationsCountLabel.frame = CGRect(x: 20, y: 0 , width: 20, height: 20)
        notificationsCountLabel.backgroundColor = UIColor.white
        notificationsCountLabel.layer.cornerRadius = 10
        notificationsCountLabel.layer.masksToBounds = true
        notificationsCountLabel.textAlignment = .center
        notificationsCountLabel.font = UIFont.museoSans700FontOfSize(10)
        notificationsCountLabel.textColor = UIColor.navBarEndColor()
        updateNotificationsCountInfo()
        return notificationsCountLabel
    }
    
    func dealWithActivityNotificationsUI(_ menuButton: UIButton) {
        if SharedManager.sharedInstance.notificationCount > 0 {
            menuButton.addSubview(getConfigureNotificationCountLabel())
        }
    }
    
    func foundModificationsInUserActivityNotifications() {
        if notificationsCountLabel == nil { // 'notificationsCountLabel' is not added yet, So adding it
            if let button = hamburgerMenuButton {
                dealWithActivityNotificationsUI(button)
            } else {
                print("hamburgerMenuButton found nil for some reason")
            }
        } else { // 'notificationsCountLabel' is added already, So updating the count
            updateNotificationsCountInfo()
        }
    }
    
    func updateNotificationsCountInfo() {
        DispatchQueue.main.async { () -> Void in
            if self.notificationsCountLabel != nil {
                let count = "\(SharedManager.sharedInstance.notificationCount)"
                if SharedManager.sharedInstance.notificationCount == 0 {
                    self.notificationsCountLabel.removeFromSuperview()
                    self.notificationsCountLabel = nil
                    return;
                }
                
                //                print("Updated 'notificationsCountLabel' with count: \(count)")
                self.notificationsCountLabel.text = count
                self.notificationsCountLabel.updateWidthAsPerNotificationCount()
            }
        }
    }
    
    //
    
}

// MARK:- ---> Indicator
extension BaseVC {
    func showIndicator() {
        if indicatorView == nil {
            indicatorView = CustomActivityIndicator()
            self.view.addSubview(indicatorView!)
        }
    }
    
    func showIndicator(blockUI blockUIFlag: Bool) {
        showIndicator()
        if blockUIFlag {
            view.window?.isUserInteractionEnabled = false
        }
    }
    
    func showIndicatorOn(_ sender: AnyObject) {
        showIndicatorOn(sender, forceToRight: false)
    }
    
    func showIndicatorOn(_ sender: AnyObject, forceToRight: Bool) {
        if indicatorView == nil {
            indicatorView = CustomActivityIndicator()
            indicatorView?.forceToRight = forceToRight
            sender.addSubview(indicatorView!)
        }
    }
    
    func showIndicatorOn(_ sender: AnyObject, blockUIFlag: Bool) {
        showIndicatorOn(sender, blockUIFlag: blockUIFlag, forceToRight: false)
    }
    
    func showIndicatorOn(_ sender: AnyObject, blockUIFlag: Bool, forceToRight: Bool) {
        showIndicatorOn(sender, forceToRight: forceToRight)
        if blockUIFlag {
            view.window?.isUserInteractionEnabled = false
        }
    }
    
    func hideIndicator() {
        if indicatorView != nil {
            indicatorView?.removeIndicator()
            indicatorView = nil
            view.window?.isUserInteractionEnabled = true
        }
    }
}

