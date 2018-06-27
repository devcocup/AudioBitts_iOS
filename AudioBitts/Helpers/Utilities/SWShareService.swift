//
//  SWShareService.swift
//  Switch
//
//  Created by Conny Hung on 8/2/17.
//  Copyright © 2017 Conny Hung. All rights reserved.
//

import UIKit
import MessageUI
import Photos
//import TwitterKit
import SVProgressHUD

class SWShareService: NSObject, MFMailComposeViewControllerDelegate {

    static let sharedInstance = SWShareService()
    
    var fromViewController: UIViewController? = nil
    
    func shareByFacebook(shareData: Data) {
    }
    
    func shareByTwitter(shareData: Data, completionHandler: @escaping (_ success: Bool) -> Void) -> Bool {
        let twitterUpload = TwitterVideoUpload.instance()!
        twitterUpload.setVideoData(shareData)
        twitterUpload.statusContent = "You can create your own bitts with #AudioBitts App!"
        SVProgressHUD.show()
        let status = twitterUpload.upload { (error: String?) in
            SVProgressHUD.dismiss()
            if error != nil {
                print(error!)
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
        if status == false {
            SVProgressHUD.dismiss()
            return false
        }

        return true
    }
    
    func postTwitterVideo(videoData: Data) {
        let twitterUpload = TwitterVideoUpload()
        let params = ["text" : "You can create your own bitts with #AudioBitts App!"]
        twitterUpload.share(toTwitter: videoData, params: params)
    }
    
    func shareByInstagram(videoURL: URL?) {
    }
    
    func shareByEmail(shareData: Data) {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("Switch")
            controller.setMessageBody("", isHTML: false)
            controller.addAttachmentData(shareData, mimeType: "video/mov", fileName: "video.mov")
            self.fromViewController?.present(controller, animated: true, completion: nil)
        } else {
            
        }
    }
    
    func shareTo(shareData: Data, fileURL: URL!) {
        let message = "You can create your own bitts with the #AudioBitts App!"
        let items = [message, fileURL] as [Any]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.setValue("Switch", forKey: "subject")
        controller.modalPresentationStyle = .popover
        self.fromViewController?.present(controller, animated: true, completion: {
        })
        
        let popoverController = controller.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        controller.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed == true {
            } else {
                print("An error occured: \(error?.localizedDescription)")
            }
        }
    }
    
    func saveVideo(fileURL: URL, _ completionHandler: @escaping (_ success: Bool, _ url: URL?, _ videoData: Data?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                    DispatchQueue.main.async {
                        let asset = avurlAsset as! AVURLAsset
                        print(asset.url)
                        // This is the URL we need now to access the video from gallery directly.
                        do {
                            let videoData = try Data(contentsOf: asset.url)
                            completionHandler(saved, asset.url, videoData)
                        } catch {
                            completionHandler(saved, asset.url, nil)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completionHandler(saved, nil, nil)
                }
            }
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
