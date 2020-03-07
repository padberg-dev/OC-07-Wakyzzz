//
//  NotificationCreator.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 07/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import NotificationCenter

// Struct for passing data into Notification
struct NotificationData {
    
    let notificationIdentifier: String
    let categoryIdentifier: String
    let title: String
    let subtitle: String
    let body: String
    let soundType: SoundType
    let volume: Float
}

enum SoundType: String {
    case basic = "defaultSound.mp3"
    case evil = "evilSound.mp3"
}

class NotificationCreator {
    
    // Enum for differentiating which notification needs to be created
    enum NotificationType {
        case notification(alarm: Alarm, weekDay: Int?)
        case snooze(count: Int)
        case deferMore
    }
    
    // Enum for differentiating which action needs to be added
    // String name will be used to compare
    enum NotificationActionType: String {
        case snooze
        case secondSnooze
        case textFriend
        case textFamily
        case delete
        case deferMore
        case complete
    }
    
    // MARK: - Public Methods
    
    public func getSound(type: SoundType, volume: Float) -> UNNotificationSound {
        
        return UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(string: type.rawValue) as String, withAudioVolume: volume)
    }
    
    public func getActions(types: [NotificationActionType]) -> [UNNotificationAction] {
        
        var array: [UNNotificationAction] = []
        types.forEach {
            array.append(createAction(of: $0))
        }
        return array
    }
    
    // It creates an action with title
    private func createAction(of type: NotificationActionType) -> UNNotificationAction {
        
        var title = ""
        var options: UNNotificationActionOptions = []

        switch type {
        case .snooze:
            title = "Snooze"
        case .secondSnooze:
            title = "Snooze Again"
        case .textFriend:
            title = "Text a Friend"
        case .textFamily:
            title = "Text a Family Member"
        case .delete:
            title = "Stop Alarm"
            options = .destructive
        case .deferMore:
            title = "I'll complete it later!"
        case .complete:
            title = "Yes, I've completed it!"
            options = .destructive
        }
        return UNNotificationAction(identifier: type.rawValue, title: title, options: options)
    }
}
