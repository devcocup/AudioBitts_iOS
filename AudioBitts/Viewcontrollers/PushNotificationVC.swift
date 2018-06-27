//
//  PushNotificationVC.swift
//  AudioBitts
//
//  Created by Phani on 2/1/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse



class PushNotificationVC: BaseMainVC {
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    var menuItemsInfoArray = ["Likes","Comments","New Followers","Tags"]
    var user :ABUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        self.title = "Push Notification"
        // Do any additional setup after loading the view.
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = ABUser(pfUser: PFUser.current()!)
    }
}

extension PushNotificationVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemsInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PushNotificationTVCellIdentifier", for: indexPath) as! PushNotificationTVCell
        cell.nameLabel.text = menuItemsInfoArray[indexPath.row]
        cell.notificationSwitch.isOn = true
        cell.notificationType = .Likes
        if (indexPath.row == 0) {
            cell.notificationSwitch.setOn((user?.isNotifyLikes)!, animated: false)
        } else if (indexPath.row == 1) {
            cell.notificationSwitch.setOn((user?.isNotifyComments)!, animated: false)
        } else if (indexPath.row == 2) {
            cell.notificationSwitch.setOn((user?.isNotifyNewFollowers)!, animated: false)
        } else {
            cell.notificationSwitch.setOn((user?.isNotifyTags)!, animated: false)
        }
        return cell
    }
}
extension PushNotificationVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
}

