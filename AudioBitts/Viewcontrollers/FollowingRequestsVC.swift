//
//  FollowingRequestsVC.swift
//  AudioBitts
//
//  Created by Ashok on 12/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import Parse

class FollowingRequestsVC: BaseVC {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    var usersArray = [ABUser]()
    var notificationsArray: [ABNotification]!
    var didChangeNotificationsInfo: ((_ notifications: [ABNotification]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Requests"
        usersTableView.register(UINib(nibName: "FollowingRequestTVCell", bundle: nil), forCellReuseIdentifier: "FollowingRequestTVCell_ID")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK:- Table View Datasource and Delegates
extension FollowingRequestsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let requestsCell = tableView.dequeueReusableCell(withIdentifier: "FollowingRequestTVCell_ID", for: indexPath) as! FollowingRequestTVCell
        requestsCell.delegate = self
        requestsCell.indexPath = indexPath
        requestsCell.sourceClass = self
        requestsCell.user = usersArray[indexPath.row]
        return requestsCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //
    //    }
}

// MARK:-
extension FollowingRequestsVC: FollowingRequestTVCellDelegate {
    func didActOnRequest(_ indexPath: IndexPath, tag: Int) {
        let user = usersArray[indexPath.row]
        var indexesToDelete = [Int]()
        for i in 0 ..< notificationsArray.count {
            let notification = notificationsArray[i]
            if notification.fromUser?.objectId == user.objectId && notification.type == .requested {
                // Storing indexes to delete it from array
                indexesToDelete.append(i)
                
                // Deleting notification from Parse
                let notificationObject =  PFObject(withoutDataWithClassName: "Notification", objectId: notification.objectId)
                notificationObject.deleteInBackground()
            }
        }
        
        if indexesToDelete.count > 0 {
            // Deleting indexes
            for index in indexesToDelete {
                notificationsArray.remove(at: index)
            }
            
            if let didChangeNotificationsInfo = didChangeNotificationsInfo {
                didChangeNotificationsInfo(notificationsArray)
            }
        }
    }
}
