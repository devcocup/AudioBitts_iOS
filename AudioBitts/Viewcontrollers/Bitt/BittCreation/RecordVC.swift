//
//  RecordVC.swift
//  CamPlusAudio
//
//  Created by Ashok on 11/12/15.
//  Copyright © 2015 Ashok. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

class RecordVC: UIViewController  {
    
    var myPickerController =  UIImagePickerController()
    var capturedImages = [UIImage]()
    var selectionImageView = UIImageView()
    var baseView = UIView()
    var collectionView = UIImageView()
    var ccControlsVCInstance: CustomCameraControlsVC!
    var selectionVCInstance: SelectionVC!
    var videoDuration = 0
    var addButton:UIButton!
    var userDefaults = UserDefaults()
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImagePickerController()
        checkForRecordingFirstTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Implementation of functions
    func checkForRecordingFirstTime() {
        if !userDefaults.bool(forKey: "Record_First") {
            userDefaults.set(true, forKey: "Record_First")
            let demoViewInstance = storyboard!.instantiateViewController(withIdentifier: "DemoAlertVC_ID") as! DemoAlertVC
            configureChildViewController(demoViewInstance, onView: self.view)
        }
    }
    func plusButtonAction() {
        selectionVCInstance.plusBtnAction()
    }
    //MARK: Configure ImagePicker
    func configureImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            myPickerController.delegate = self
            myPickerController.sourceType = .camera;
            myPickerController.mediaTypes = [kUTTypeMovie as String]
            myPickerController.allowsEditing = false
            myPickerController.extendedLayoutIncludesOpaqueBars = true
            myPickerController.cameraOverlayView = getCameraOverlayView()
            myPickerController.showsCameraControls = false
            myPickerController.cameraDevice = .rear
            myPickerController.cameraFlashMode = .off
            myPickerController.videoQuality = .typeHigh
            configureChildViewController(myPickerController, onView: nil)
            
            let navigationBarView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
            navigationBarView.backgroundColor = UIColor.black
            let backButton = UIButton(type: UIButtonType.custom)
            backButton.frame = CGRect(x: 0, y: 0 , width: 45, height: 45)
            backButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 7, 10)
            backButton.setImage(UIImage(named: "Cancel"), for: UIControlState())
            backButton.addTarget(self, action: #selector(RecordVC.backBtnClicked), for: UIControlEvents.touchUpInside)
            navigationBarView.addSubview(backButton)
            view.addSubview(navigationBarView)
            
            addButton = UIButton(type: UIButtonType.custom)
            addButton.frame = CGRect(x: view.frame.width - 45, y: 0 , width: 45, height: 45)
            addButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 7, 10)
            addButton.setImage(UIImage(named: "Plus"), for: UIControlState())
            addButton.isHidden = true
            addButton.addTarget(self, action: #selector(RecordVC.plusButtonAction), for: UIControlEvents.touchUpInside)
            navigationBarView.addSubview(addButton)
            view.addSubview(navigationBarView)
            
            selectionImageView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 222)
            print(selectionImageView.frame)
            selectionImageView.isHidden = true
            selectionImageView.image = UIImage(named: "splashImage")
            selectionImageView.isUserInteractionEnabled = true
            selectionImageView.backgroundColor = UIColor.red
            view.addSubview(selectionImageView)
            addSelectionVC()
            
            collectionView.frame = CGRect(x: 0, y: 45, width: view.frame.width, height: view.frame.height - 148)
            collectionView.isHidden = true
            view.addSubview(collectionView)
            
            baseView.isHidden = true
            baseView = UIView(frame: CGRect(x: 0, y: view.frame.height - 180, width: view.frame.width, height: 180))
            view.addSubview(baseView)
            addCameraControlsView()
        } else {
            perform(#selector(RecordVC.handleIfCameraIsNotAvailable), with: nil, afterDelay: 1)
        }
    }
    func backBtnClicked() {
        dismiss(animated: true, completion: nil)
        capturedImages.removeAll()
        myPickerController.dismiss(animated: true, completion: nil)
    }
    
    func getCameraOverlayView() -> UIView {
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        overlayView.backgroundColor = UIColor.clear
        
        let controlsHolderView = UIView(frame: CGRect(x: 0, y: view.frame.height - 180, width: view.frame.width, height: 220))
        controlsHolderView.backgroundColor = UIColor.white
        overlayView.addSubview(controlsHolderView)
        addCameraControls(to: controlsHolderView)
        return overlayView
    }
    func addCameraControlsView() {
        ccControlsVCInstance = storyboard!.instantiateViewController(withIdentifier: "CustomCameraControlsVC_ID") as! CustomCameraControlsVC
        ccControlsVCInstance.delegate = self
        configureChildViewController(ccControlsVCInstance, onView: baseView)
    }
    
    func addSelectionVC() {
        selectionVCInstance = storyboard!.instantiateViewController(withIdentifier: "SelectionVC_ID") as! SelectionVC
        selectionVCInstance.deleagate = self
        configureChildViewController(selectionVCInstance, onView: selectionImageView)
    }
    
    func addCameraControls(to controlsHolderView: UIView) {
        ccControlsVCInstance = storyboard!.instantiateViewController(withIdentifier: "CustomCameraControlsVC_ID") as! CustomCameraControlsVC
        ccControlsVCInstance.delegate = self
        configureChildViewController(ccControlsVCInstance, onView: controlsHolderView)
    }
    
    func getPreviewImageForVideoAtURL(_ videoURL: URL, atInterval: Int) -> UIImage? {
        print("Taking pic at \(atInterval) second")
        let asset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //        http://stackoverflow.com/a/6303604/1996294
        let time = CMTimeMakeWithSeconds(Float64(atInterval), 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg = UIImage(cgImage: img)
            
            
            return frameImg
        }
        catch {/* error handling here */}
        return nil
    }
    
    func cropImageToVisibleArea(_ image: UIImage, rect: CGRect) -> UIImage {
        let screenSize = UIScreen.main.bounds
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let contextSize: CGSize = contextImage.size
        
        let yPercent = (100 / screenSize.height) * rect.minY
        let posY = (contextSize.height / 100) * yPercent
        
        let heightPercent = (100 / screenSize.height) * rect.height
        let cgHeight = (contextSize.height / 100) * heightPercent
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: CGRect(x: 0, y: posY, width: contextSize.width, height: cgHeight))!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func processImagesWithVideo(_ url: URL) {
        var image1 = getPreviewImageForVideoAtURL(url, atInterval: 1)!
        image1 = cropImageToVisibleArea(image1, rect: selectionImageView.frame)
        capturedImages.append(image1)
        
        if videoDuration >= 3 {
            let count = Int(videoDuration / 3)
//            for var i = 1; i <= count; i += 1 {
            for var i in 1...count {
                var image2 = getPreviewImageForVideoAtURL(url, atInterval: i * 3)!
                image2 = cropImageToVisibleArea(image2, rect: selectionImageView.frame)
                capturedImages.append(image2)
            }
        }
        
        selectionImageView.isHidden = false
        baseView.isHidden = false
        scatterChildViewController(myPickerController)
        if capturedImages.count > 5 {
            let endIndex = capturedImages.count - 5
            capturedImages.removeSubrange(0..<endIndex)
        }
        selectionVCInstance.images = capturedImages
        selectionVCInstance.reloadCollectionView()
        addButton.isHidden = false
    }
    
    //    func showSelectionVC() {
    //
    //        if capturedImages.count > 5 {
    //            let endIndex = capturedImages.count - 5
    //            capturedImages.removeRange(0..<endIndex)
    //        }
    //
    //        scatterChildViewController(myPickerController)
    //
    //        let selectionVCInstance = storyboard!.instantiateViewControllerWithIdentifier("SelectionVC_ID") as! SelectionVC
    //        selectionVCInstance.images = self.capturedImages
    //        let navigationVC = UINavigationController()
    //        navigationVC.viewControllers = [selectionVCInstance]
    //
    //        self.presentViewController(navigationVC, animated: true, completion: nil)
    //    }
}
//MARK:- SelectionVCDelegate
extension RecordVC: SelectionVCDelegate {
    func reloadCollectionView() {
        print("Reload CollectionView")
    }
}
//MARK:- CustomCameraControlsVCDelegate
extension RecordVC: CustomCameraControlsVCDelegate {
    func didClickStartRecordingButton(_ sender: UIButton) {
        if !myPickerController.startVideoCapture() {
            print("Not able to initiate startVideoCapture")
        }
    }
    
    func didClickStopRecordingButton(_ sender: UIButton, duration: Int) {
        if (myPickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on) {
            myPickerController.cameraFlashMode = .off
        }
        videoDuration = duration
        myPickerController.stopVideoCapture()
        if !userDefaults.bool(forKey: "Post_First") {
            userDefaults.set(true, forKey: "Post_First")
            let demoViewInstance = storyboard!.instantiateViewController(withIdentifier: "DemoVC_ID") as! DemoVC
            configureChildViewController(demoViewInstance, onView: self.view)
        }
    }
    
    func didClickCancelButtion() {
        dismiss(animated: true, completion: nil)
        capturedImages.removeAll()
        myPickerController.dismiss(animated: true, completion: nil)
    }
    
    func didClickFlashButton() {
        if (myPickerController.cameraFlashMode == UIImagePickerControllerCameraFlashMode.on) {
            myPickerController.cameraFlashMode = .off
        } else {
            myPickerController.cameraFlashMode = .on
        }
    }
    
    func didClickSwitchCameraButton() {
        if (myPickerController.cameraDevice == UIImagePickerControllerCameraDevice.front) {
            myPickerController.cameraDevice = .rear
        } else {
            myPickerController.cameraDevice = .front
        }
    }
    
    func didClickNextButton() {
        //showSelectionVC()
        selectionVCInstance.seekTimeString = ccControlsVCInstance.audioDurationLabel.text!
        selectionVCInstance.rightBarButtionClicked(UIButton())
    }
    
}

extension RecordVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            processImagesWithVideo(info[UIImagePickerControllerMediaURL] as! URL)
        }
    }
}

// MARK:- Exceptions
extension RecordVC {
    func handleIfCameraIsNotAvailable() {
        let alert = UIAlertController(title: "Sorry!", message: "You cannot work through Camera when it's not available!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
