//
//  UserActivityNotificationsHandler.swift
//  AudioBitts
//
//  Created by Ashok on 01/04/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation

let userActivityNotificationIdentifier = "UserActivityNotificationIdentifier"

func startListeningToUserActivityNotifications(_ classObject: AnyObject) {
    NotificationCenter.default.addObserver(classObject, selector: "foundModificationsInUserActivityNotifications", name: NSNotification.Name(rawValue: userActivityNotificationIdentifier), object: nil)
}

func stopListeningToUserActivityNotifications(_ classObject: AnyObject) {
    NotificationCenter.default.removeObserver(classObject, name: NSNotification.Name(rawValue: userActivityNotificationIdentifier), object: nil)
}

func notifyUserActivityNotificationsListeners() {
    NotificationCenter.default.post(name: Notification.Name(rawValue: userActivityNotificationIdentifier), object: nil)
}
