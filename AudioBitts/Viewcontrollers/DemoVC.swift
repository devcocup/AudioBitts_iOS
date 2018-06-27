//
//  DemoVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 09/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

class DemoVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DemoVC.viewTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.view.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func viewTapped() {
        print("disniss")
        view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
