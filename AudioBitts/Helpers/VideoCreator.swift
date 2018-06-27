//
//  VideoCreator.swift
//  AudioBitts
//
//  Created by admin on 10/7/17.
//  Copyright © 2017 mobileways. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCreator: NSObject {
    
    static let sharedInstance = VideoCreator()
    
    // See AVAssetExportSession.h for quality presets.
    public func createMovieWithSingleImageAndMusic(image: UIImage, audioFileURL: URL, assetExportPresetQuality: String, completion: @escaping (URL?, Error?) -> ()) {
        let audioAsset = AVURLAsset(url: audioFileURL)
        let length = TimeInterval(audioAsset.duration.seconds)
        
        var outputPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("outputVideo.mov")
        unlink((outputPath as NSString).utf8String)
        let outputVideoFileURL = URL(fileURLWithPath: outputPath);
        
        self.writeSingleImageToMovie(image: image, movieLength: length, outputFileURL: outputVideoFileURL) { (error: Error?) in
            if let error = error {
                completion(nil, error)
                return
            }
            let videoAsset = AVURLAsset(url: outputVideoFileURL)
            outputPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("mergedVideo.mov")
            unlink((outputPath as NSString).utf8String)
            let videoFileURL = URL(fileURLWithPath: outputPath);
            self.addAudioToMovie(audioAsset: audioAsset, inputVideoAsset: videoAsset, outputVideoFileURL: videoFileURL, quality: assetExportPresetQuality) { (error: Error?) in
                if let error = error {
                    completion(nil, error)
                    return
                } else {
                    completion(videoFileURL, error)
                }
            }
        }
    }
    
    func addAudioToMovie(audioAsset: AVURLAsset, inputVideoAsset: AVURLAsset, outputVideoFileURL: URL, quality: String, completion: @escaping (Error?) -> ()) {
        do {
            let composition = AVMutableComposition()
            
            guard let videoAssetTrack = inputVideoAsset.tracks(withMediaType: AVMediaTypeVideo).first else { throw NSError.init() }
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, inputVideoAsset.duration), of: videoAssetTrack, at: kCMTimeZero)
            
            let audioStartTime = kCMTimeZero
            guard let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaTypeAudio).first else { throw NSError.init() }
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset.duration), of: audioAssetTrack, at: audioStartTime)
            
            guard let assetExport = AVAssetExportSession(asset: composition, presetName: quality) else { throw NSError.init() }
            assetExport.outputFileType = AVFileTypeQuickTimeMovie
            assetExport.outputURL = outputVideoFileURL
            
            assetExport.exportAsynchronously {
                completion(assetExport.error)
            }
        } catch {
            completion(error)
        }
    }
    
    func writeSingleImageToMovie(image: UIImage, movieLength: TimeInterval, outputFileURL: URL, completion: @escaping (Error?) -> ()) {
        do {
            let imageSize = image.size
            let videoWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: AVFileTypeQuickTimeMovie)
            let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                                AVVideoWidthKey: imageSize.width,
                                                AVVideoHeightKey: imageSize.height]
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            
            if !videoWriter.canAdd(videoWriterInput) { throw NSError.init() }
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.add(videoWriterInput)
            
            videoWriter.startWriting()
            let timeScale: Int32 = 600 // recommended in CMTime for movies.
            let halfMovieLength = Float64(movieLength/2.0) // videoWriter assumes frame lengths are equal.
            let startFrameTime = CMTimeMake(0, timeScale)
            let endFrameTime = CMTimeMakeWithSeconds(halfMovieLength, timeScale)
            videoWriter.startSession(atSourceTime: startFrameTime)
            
            guard let cgImage = image.cgImage else { throw NSError.init() }
            let buffer: CVPixelBuffer = try self.pixelBuffer(fromImage: cgImage, size: imageSize)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: startFrameTime)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: endFrameTime)
            
            videoWriterInput.markAsFinished()
            videoWriter.finishWriting {
                completion(videoWriter.error)
            }
        } catch {
            completion(error)
        }
    }    
    
    func pixelBuffer(fromImage image: CGImage, size: CGSize) throws -> CVPixelBuffer {
        let options: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true] as CFDictionary
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pxbuffer)
        guard let buffer = pxbuffer, status == kCVReturnSuccess else { throw NSError.init() }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer) else { throw NSError.init() }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { throw NSError.init() }
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }

}
