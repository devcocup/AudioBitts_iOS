//
//  DemoAlertVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 09/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class DemoAlertVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAlertView(_ sender: AnyObject) {
        view.removeFromSuperview()
    }
    
}
