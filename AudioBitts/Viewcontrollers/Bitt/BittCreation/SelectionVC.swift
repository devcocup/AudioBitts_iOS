//
//  SelectionVC.swift
//  CamPlusAudio
//
//  Created by Ashok on 10/12/15.
//  Copyright © 2015 Ashok. All rights reserved.
//

import UIKit

protocol SelectionVCDelegate: class {
    func reloadCollectionView()
}

extension SelectionVCDelegate {
    func reloadCollectionView() { }
}

class SelectionVC: BaseMainVC {
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var counter = 0
    var timer :Timer!
    var images = [UIImage]()
    var picker = UIImagePickerController()
    var seekTimeString = String()
    var selectedIndex: Int?
    weak var deleagate:SelectionVCDelegate?
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Select Cover"
        configureRightBarButton()
        configureBackButton()
        picker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Configure UI
    override func configureBackButton() {
        addLeftBarButton("Cancel")
    }
    
    override func backBtnClicked() {
        cancelBtnAction()
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Upload")
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        submmitBtnAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK:- Implementation of functions
    func reloadCollectionView() {
        imagesCollectionView.reloadData()
    }
    
    func dismissSelf() {
        dismiss(animated: false) { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sharingStatus"), object: nil, userInfo: ["succeeded" : false])
        }
    }
    func isFieldInformationValid() -> Bool {
        view.endEditing(true)
        
        if selectedIndex == nil {
            showAlert("Image is mandatory!", message: "Please select one image.", on: self)
            return false
        }
        
        return true
    }
    
    // MARK:- IBActions
    func cancelBtnAction() {
        dismissSelf()
    }
    
    func submmitBtnAction() {
        if isFieldInformationValid() {
            
            let shareVC = storyboard!.instantiateViewController(withIdentifier: "ShareVC_ID") as! ShareVC
            shareVC.title = "Add Title"
            shareVC.selectedImage = images[selectedIndex!]
            shareVC.countValue = seekTimeString
            let navigationVC = UINavigationController()
            navigationVC.viewControllers = [shareVC]
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    func plusBtnAction() {
        let vc = VKActionController()
        
        vc.addAction(VKAction(title: "Photo gallary", image: UIImage(named: "photo_library"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
            
            self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(self.picker, animated: true, completion: nil)
            
            })
        vc.addAction(VKAction(title: "Take selfie", image: UIImage(named: "take_selfi"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                self.picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.picker, animated: true, completion: nil)
            }
            })
        
        vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
            })
        present(vc, animated: true, completion: nil)
        
    }
}

// MARK:- UICollectionViewDataSource & Delegates
extension SelectionVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView:  UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCVCellIdentifier",
                for: indexPath) as! SelectionCVCell
            cell.bitImageView.image = images[indexPath.row]
            cell.countLabel.text = "\(indexPath.row + 1)"
            cell.countLabel.layer.borderColor = UIColor.white.cgColor
            if let index = selectedIndex {
                if index == indexPath.row {
                    cell.isPicSelected = true
                } else {
                    cell.isPicSelected = false
                }
            } else {
                cell.isPicSelected = false
            }
            return cell
    }
    
    //Use for size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            return CGSize(width: view.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var previousIndex: Int?
        if let index = selectedIndex {
            previousIndex = index
            if selectedIndex == indexPath.row {
                selectedIndex = nil
            } else {
                selectedIndex = indexPath.row
                collectionView.reloadItems(at: [IndexPath(row: selectedIndex!, section: 0)])
            }
            
        } else {
            selectedIndex = indexPath.row
            collectionView.reloadItems(at: [IndexPath(row: selectedIndex!, section: 0)])
        }
        
        if let index = previousIndex {
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
        print("selectedIndex: \(selectedIndex)")
    }
}

extension SelectionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismiss(animated: false) { () -> Void in
            self.selectedIndex = 0
            self.images.insert(chosenImage, at: 0)
            self.imagesCollectionView.reloadData()
            self.imagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}



