//
//  VKActionController.swift
//  VKActionSheet
//
//  Created by Vamsi on 23/12/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import UIKit

class VKActionController: UIViewController {
    
    let cellIdentifier = "ActionCell"
    var actions: [VKAction] = []
    let itemHeight = 75
    var heightConstraint : NSLayoutConstraint!
    var tableBottomConstraint : NSLayoutConstraint!
    
    var tap: UITapGestureRecognizer?
    var tableView : UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(VKActionController.handleTap(_:)))
        
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        // Table View
        
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: "VKActionCell", bundle:nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //pin 100 points from the top of the super
        heightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(itemHeight * actions.count))
        tableBottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal,
            toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal,
            toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal,
            toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        
        view.addConstraints([heightConstraint, tableBottomConstraint, pinLeft, pinRight])
        
        // Top View
        let topView = UIView(frame: CGRect.zero)
        topView.backgroundColor = UIColor.clear
        view.addSubview(topView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        let pinLeft1 = NSLayoutConstraint(item: topView, attribute: .left, relatedBy: .equal,
            toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight1 = NSLayoutConstraint(item: topView, attribute: .right, relatedBy: .equal,
            toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        let pinTop = NSLayoutConstraint(item: topView, attribute: .top, relatedBy: .equal,
            toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal,
            toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0)
        
        view.addConstraints([pinLeft1,pinRight1,pinTop,pinBottom])
        topView.addGestureRecognizer(tap!)
        tableView.isHidden = true
        
        configureUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        doSomeAnimationStuff()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAction(_ action: VKAction) {
        actions.append(action)
    }
    
    func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        dismissPicker(nil)
    }
    
    func configureUI() {
        self.view.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.alpha = 1
        })
    }
    
    func doSomeAnimationStuff() {
        
        tableBottomConstraint.constant = CGFloat(itemHeight * actions.count)
        tableView.layoutIfNeeded()
        tableView.isHidden = false
        tableBottomConstraint.constant = 1
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.tableView.layoutIfNeeded()
            }, completion: { finished in
        })
    }
    
    // MARK:- Dismiss picker with delegates
    
    func dismissPicker(_ action: VKAction?) {
        
        let window :UIWindow = UIApplication.shared.keyWindow!
        var tempFrame = self.tableView.frame
        tempFrame.origin.y = window.frame.height
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.tableView.frame = tempFrame
            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
            
            }, completion: {_ in
                self.dismiss(animated: false, completion: nil)
                if let act = action{
                    act.handler?(act)
                }
        })
        
        
    }
}


extension VKActionController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VKActionCell
        
        let action = actions[indexPath.row]
        cell.titleLabel.text = action.title
        cell.contentView.backgroundColor = action.bgcolor
        cell.cancelLabel.text = action.cancelTitle
        if let image = action.image {
            cell.actionImageView.image = image
            cell.centerConstraint.constant = 24
        } else {
            cell.centerConstraint.constant = 0
        }
        
        return cell
    }
}

extension VKActionController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let action = actions[indexPath.row]
        dismissPicker(action)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
