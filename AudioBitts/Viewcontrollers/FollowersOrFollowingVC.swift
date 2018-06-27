//
//  FollowersOrFollowingVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 20/01/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

enum PersonRelationType {
    case follow, following, requested, unblock, currentUser
}

enum FollowersOrFollowingType {
    case followers, following
}

class FollowersOrFollowingVC: BaseMainVC {
    
    @IBOutlet weak var followTableView: UITableView!
    
    var users = [ABUser]()
    var infoType: FollowersOrFollowingType = .followers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        followTableView.register(UINib(nibName: "FollowTVCell", bundle: nil), forCellReuseIdentifier: "FollowTVCell_ID")
        configureBackButton()
        if infoType == .followers {
            self.title = "Followers"
        } else {
            self.title = "Following"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func configureBackButton() {
        addBackButton()
    }
}

//MARK:- Tableview DataSource
extension FollowersOrFollowingVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTVCell_ID", for: indexPath) as! FollowTVCell
        cell.userInfo = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let profileVCInstance = storyboard?.instantiateViewController(withIdentifier: "ProfileVC_ID") as! ProfileVC
        profileVCInstance.isFollow = true
        profileVCInstance.userInformation = user
        profileVCInstance.profileNavigationSource = ProfileVCNavigationSource.followersOrFollowingVC
        navigationController?.pushViewController(profileVCInstance, animated: true)
    }
    
}
