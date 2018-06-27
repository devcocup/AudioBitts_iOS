//
//  FileManager.swift
//  AudioBitts
//
//  Created by Vamsi on 28/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import Foundation

class FileManager {
    
    static let sharedInstance = FileManager()
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    func saveFile(_ name:String, data: Data) -> String?{
        do {
            let fileManager = Foundation.FileManager.default
            let audiosPath = documentsPath + "/AudioFiles"
            if !fileManager.fileExists(atPath: audiosPath) {
                try fileManager.createDirectory(atPath: audiosPath, withIntermediateDirectories: false, attributes: nil)
            }
            
            let savePath = audiosPath + "/" + "\(name).aac"
            Foundation.FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
            return savePath;
        } catch {
            print("Error while getting files count")
            return nil
        }
    }
    
    func checkIfExists(_ name:String) -> String? {
        let filePath = documentsPath + "/AudioFiles/" + "\(name).aac"
        if Foundation.FileManager.default.fileExists(atPath: filePath) {
            return filePath;
        }
        return nil
    }
    
    func isSaveFileSuccess(_ name:String, data: Data) -> Bool {
        do {
            let fileManager = Foundation.FileManager.default
            let audiosPath = documentsPath + "/AudioFiles"
            if !fileManager.fileExists(atPath: audiosPath) {
                try fileManager.createDirectory(atPath: audiosPath, withIntermediateDirectories: false, attributes: nil)
            }
            
            let savePath = audiosPath + "/" + "\(name).aac"
            Foundation.FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
            return true
        } catch {
            print("Error while getting files count")
            return false
        }
    }
    
    func isAudioFileExists(_ name:String) -> Bool {
        let filePath = documentsPath + "/AudioFiles/" + "\(name).aac"
        if Foundation.FileManager.default.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
    
    func audioFileURL(_ feedObjectId: String) -> URL? {
        let filePath = documentsPath + "/AudioFiles/" + "\(feedObjectId).aac"
        if Foundation.FileManager.default.fileExists(atPath: filePath) {
            return URL(fileURLWithPath: filePath)
        }
        return nil
    }
}
