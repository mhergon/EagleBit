//
//  Extensions.swift
//  Eaglebit
//
//  Created by mhergon on 25/10/17.
//  Copyright © 2017 mhergon. All rights reserved.
//

import UserNotifications

extension Eaglebit {
    
    func showNotification(message: String) {
        
        // Show notification
        let content = UNMutableNotificationContent()
        content.title = "Eaglebit"
        content.body = message
        content.categoryIdentifier = "state"
        content.sound = .default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
}
