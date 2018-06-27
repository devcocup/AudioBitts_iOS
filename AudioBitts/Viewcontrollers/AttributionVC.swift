//
//  AttributionVC.swift
//  AudioBitts
//
//  Created by Navya on 05/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class AttributionVC: BaseMainVC {
    
    @IBOutlet weak var attributionTextLabel: UILabel!

    @IBOutlet weak var attributionTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Attribution"
        
        attributionTextLabel.text = SharedManager.sharedInstance.attributionText
        
        attributionTableView.dataSource = self
        attributionTableView.delegate = self
        
        self.attributionTableView.estimatedRowHeight = 44.0
        self.attributionTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func configureBackButton() {
        addBackButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension AttributionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttributionCell", for: indexPath) as! AttributionTVCell
//        cell.libraryName.text = "lsjfdj"
        return cell
    }
}

extension AttributionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableViewAutomaticDimension
    }
}
