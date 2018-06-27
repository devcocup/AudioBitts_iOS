//
//  BaseMainVC.swift
//  AudioBitts
//
//  Created by Phani on 12/22/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

class BaseMainVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("awakeFromNib BaseMainVC")
    }
    
    //This method over rides super class implementation
    override func configureBackButton() {
        // Customizing navigation bar
        addMenuButton()
    }
    
    //    override func configureTitleView() {
    //
    //    }
    //
    //    override func setViewTitle(titlestring: String) {
    //        self.title = titlestring
    //    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        print("BaseMainVC")
    }
    
    override func configureRightBarButton(){
        
    }
    
    // MARK:- ---> Indicator
    override func showIndicator() {
        if indicatorView == nil {
            indicatorView = CustomActivityIndicator()
            self.view.addSubview(indicatorView!)
        }
    }
    
    override func showIndicator(blockUI blockUIFlag: Bool) {
        showIndicator()
        if blockUIFlag {
            self.view.isUserInteractionEnabled = false
        }
    }
    
    override func showIndicatorOn(_ sender: AnyObject) {
        showIndicatorOn(sender, forceToRight: false)
    }
    
    override func showIndicatorOn(_ sender: AnyObject, forceToRight: Bool) {
        if indicatorView == nil {
            indicatorView = CustomActivityIndicator()
            indicatorView?.forceToRight = forceToRight
            sender.addSubview(indicatorView!)
        }
    }
    
    override func showIndicatorOn(_ sender: AnyObject, blockUIFlag: Bool) {
        showIndicatorOn(sender, blockUIFlag: blockUIFlag, forceToRight: false)
    }
    
    override func showIndicatorOn(_ sender: AnyObject, blockUIFlag: Bool, forceToRight: Bool) {
        showIndicatorOn(sender, forceToRight: forceToRight)
        if blockUIFlag {
            self.view.isUserInteractionEnabled = false
        }
    }
    
    override func hideIndicator() {
        if indicatorView != nil {
            indicatorView?.removeIndicator()
            indicatorView = nil
            self.view.isUserInteractionEnabled = true
        }
    }
    
}
