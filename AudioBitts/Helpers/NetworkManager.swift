//
//  NetworkManager.swift
//  Voler
//
//  Created by Manoj on 05/10/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import Foundation
import SystemConfiguration


//func isInternetAvailable(_ canshowError: Bool = false) -> Bool {
//    var isInternetAvailable = false
//    
//    var zeroAddress = sockaddr_in()
//    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//    zeroAddress.sin_family = sa_family_t(AF_INET)
//    
//    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
//        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
//    }) else {
//        return false
//    }
//    
//    var flags : SCNetworkReachabilityFlags = []
//    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
//        return false
//    }
//    
//    let isReachable = flags.contains(.reachable)
//    let needsConnection = flags.contains(.connectionRequired)
//    
//    isInternetAvailable = (isReachable && !needsConnection)
//    
//    if !isInternetAvailable {
//        let window :UIWindow = UIApplication.shared.keyWindow!
//        let currentViewController = window.rootViewController
//        showAlert("No Internet!", message: "Please recheck your internet connection.", on: currentViewController!)
//    }
//    
//    return isInternetAvailable
//}

func isInternetAvailable(_ canshowError: Bool = false) -> Bool {
    var isInternetAvailable = false
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}
