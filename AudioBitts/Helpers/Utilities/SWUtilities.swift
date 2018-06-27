//
//  SWUtilities.swift
//  Switch
//
//  Created by Conny Hung on 8/1/17.
//  Copyright © 2017 Conny Hung. All rights reserved.
//

import UIKit
import AVFoundation

func SWDispatchMainQueueAsync(_ completionHandler: @escaping () -> Void) {
    if Thread.isMainThread == true {
        completionHandler()
    } else {
        DispatchQueue.main.async {
            completionHandler()
        }
    }
}

class SWUtilities: NSObject {
    
    static let shared = SWUtilities()
    
    var arrayVideos: Array<URL> = []
    var musicURL: URL!
    
    var mergedVideo: URL? = nil
    //var shareVideo: URL? = nil
    var shareVideoData: Data? = nil
    var username = ""
    var videoTitle = ""
    var isSaved = false
    
    func mergeVideos(completionHandler: @escaping (_ outputURL: URL?) -> Void) {
        //Create the AVmutable composition to add tracks
        let composition = AVMutableComposition()
        
        var duration = kCMTimeZero
        var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var assetTrack: AVAssetTrack!
        for i in 0..<arrayVideos.count {
            let videoURL = arrayVideos[i]
            let videoAsset = AVURLAsset(url: videoURL, options: nil)
            do {
                let tracks = videoAsset.tracks(withMediaType: AVMediaTypeVideo)
                try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: tracks[0], at: duration)
                
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
                let transform = CGAffineTransform.identity
                layerInstruction.setTransform(tracks[0].preferredTransform.concatenating(transform), at: duration)
                layerInstruction.setOpacity(1.0, at: duration)
                layerInstructions.append(layerInstruction)
                if i == 0 {
                    assetTrack = tracks[0]
                }
            } catch {
                print("error video tracks")
            }
            do {
                let tracks = videoAsset.tracks(withMediaType: AVMediaTypeAudio)
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: tracks[0], at: duration)
            } catch {
                print("error audio tracks")
            }
            
            duration = CMTimeAdd(duration, videoAsset.duration)
        }
        
        let audioAsset = AVURLAsset(url: musicURL, options: nil)
        do {
            let tracks = audioAsset.tracks(withMediaType: AVMediaTypeAudio)
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, duration), of: tracks[0], at: kCMTimeZero)
        } catch {
            print("error audio tracks")
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration)
        mainInstruction.layerInstructions = layerInstructions
        
        let mainVideoComposition = AVMutableVideoComposition()
        mainVideoComposition.instructions = [mainInstruction]
        mainVideoComposition.frameDuration = CMTimeMake(1, 24)
        let transform = assetTrack.preferredTransform
        let renderSize = assetTrack.naturalSize
        if (renderSize.width == transform.tx && renderSize.height == transform.ty) || (transform.tx == 0 && transform.ty == 0) {
            mainVideoComposition.renderSize = CGSize(width: renderSize.width, height: renderSize.height)
        } else {
            mainVideoComposition.renderSize = CGSize(width: renderSize.height, height: renderSize.width)
        }
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let videoPath = documentDirectory.appending("/SwitchVideo.mp4")
        unlink((videoPath as NSString).utf8String)
        let url = URL(fileURLWithPath: videoPath)
        //Check if the file exists then delete the old file to save the merged video file.
        if Foundation.FileManager.default.fileExists(atPath: videoPath) {
            try! Foundation.FileManager.default.removeItem(atPath: videoPath)
        }
        
        // Create the export session to merge and save the video
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        print("!!! HERE 3");
        
        exporter?.outputURL=url;
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.videoComposition = mainVideoComposition
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.timeRange = CMTimeRangeMake(kCMTimeZero, duration)
        exporter?.exportAsynchronously(completionHandler: {
            var success = false
            switch exporter!.status {
            case .failed:
                break
            case .completed:
                success = true
                break
            case .cancelled:
                break
            default:
                break
            }
            if success == true {
                completionHandler(url)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    static func addTitleShadow(button: UIButton) {
        button.setTitleShadowColor(UIColor.black.withAlphaComponent(0.4), for: .normal)
        button.titleLabel?.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
    
    static func setPurchased(_ purchased: Bool, productId: String) {
        UserDefaults.standard.set(purchased, forKey: productId)
    }
    
    static func isPurchased(_ productId: String) -> Bool {
        if UserDefaults.standard.object(forKey: productId) == nil {
            return false
        }
        return UserDefaults.standard.bool(forKey: productId)
    }
    
    static func showAlertView(_ title: String, message: String, fromController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        fromController.present(alertController, animated: true, completion: nil)
    }
}
