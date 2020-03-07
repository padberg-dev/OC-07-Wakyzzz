//
//  NManager.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 05/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import NotificationCenter

class NManager: NSObject {
    
    static let shared = NManager()
    
    public weak var delegate: NManagerDelegate?
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let creator: NotificationCreator = NotificationCreator()
    private var isNotificationEnabled: Bool = false
    
    // MARK:- Initializers
    
    override init() {
        super.init()
        
        notificationCenter.delegate = self
        cleanMissedNotifications()
    }
    
    // MARK:- Public Methods
    
    public func requestAuthorization() {
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (enabled, error) in
            self.isNotificationEnabled = enabled
        }
    }
    
    public func updateAlarmNotification(alarm: Alarm) {
        
        removePendingAlarmNotification(withId: alarm.id) {
            if alarm.enabled {

                self.addAlarmNotification(alarm)
            }
        }
    }
    
    public func removeAlarmNotification(withId id: String) {
        
        removePendingAlarmNotification(withId: id) { }
    }
    
    public func addAlarmNotification(_ alarm: Alarm) {
        
        print("::: Add New Alarm Notification")
        
        //set weekday int to sunday for loop
        var weekDay = 1
        
        //if one time set day as today
        if alarm.repeating == "One time alarm" {
            scheduleNotification(ofType: .notification(alarm: alarm, weekDay: nil))
        } else {
            for weekDayBool in alarm.repeatDays {
                if weekDayBool {
                    scheduleNotification(ofType: .notification(alarm: alarm, weekDay: nil))
                }
                weekDay += 1
            }
        }
    }
    
    // MARK:- Private Methods
    
    private func cleanMissedNotifications() {
        //catch any notification that ran when app was not active and user did not respond
        
        notificationCenter.getDeliveredNotifications { notifications in
        
            print("::: Missed Notifications: \(notifications.count)")
            
            DispatchQueue.main.async {
                notifications.forEach {
                    self.disableOneTimeAlarm(id: $0.request.identifier)
                }
            }
        }
    }
    
    private func removePendingAlarmNotification(withId id: String, completion: @escaping () -> Void) {
        
        notificationCenter.getPendingNotificationRequests { requests in
            let array = requests.filter { $0.identifier.contains(id) }
            
            print("::: removePendingAlarm arrayCount: \(array.count)")
            
            array.forEach {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [$0.identifier])
                
                self.notificationCenter.removeDeliveredNotifications(withIdentifiers: [$0.identifier])
            }
            completion()
        }
    }
    
    private func disableOneTimeAlarm(id: String) {
        
        print("::: DisablingOneTimeAlarm \(id)")
        
        let context = AppDelegate.context
        
        if let alarm = CDManager.shared.getAlarmWith(id: id, in: context) {
            //check all array items are false
            if !alarm.transformToAlarm().repeatDays.contains(true) {
                //update bool for enabled on alarm
                alarm.enabled = false
                try! context.save()
            }
        }
    }
    
    private func scheduleNotification(ofType type: NotificationCreator.NotificationType, categoryIdentifier: String? = nil, contentIdentifier: String? = nil) {
        switch type {
            
        case .notification(alarm: let alarm, weekDay: let weekDay):
            
            let data = NotificationData(
                notificationIdentifier: "\(alarm.id)\(weekDay ?? 0)",
                categoryIdentifier: alarm.caption,
                title: "WakyZzz Alarm",
                subtitle: "Wake up it's already",
                body: alarm.caption,
                soundType: .basic,
                volume: 0.5)

            guard let date = alarm.alarmDate else { return }
            //getting the notification trigger
            // The selected time to notify the user
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = weekDay ?? Calendar.current.component(.weekday, from: Date())
            dateComponents.hour = dateComponents.calendar?.component(.hour, from: date)
            dateComponents.minute = dateComponents.calendar?.component(.minute, from: date)
            
            // The time/repeat trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: weekDay != nil)
            
            createNotification(data: data, trigger: trigger, actions: [.snooze, .delete])
            
        case .snooze(count: let count):
            
            let data = NotificationData(
                notificationIdentifier: contentIdentifier ?? "",
                categoryIdentifier: categoryIdentifier ?? "",
                title: "WakyZzz",
                subtitle: count == 1 ? "First Snooze" : "Last Snooze",
                body: count == 1 ? "Alarm set for " + (categoryIdentifier ?? "") : "You now need to complete a task:",
                soundType: count == 1 ? .basic : .evil,
                volume: count == 1 ? 0.75 : 1)
            
            // The time/repeat trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            
            createNotification(data: data, trigger: trigger, actions: count == 1 ? [.secondSnooze, .delete] : [.textFriend, .textFamily, .deferMore])
        case .deferMore:
            
            let data = NotificationData(
                notificationIdentifier: contentIdentifier ?? "",
                categoryIdentifier: categoryIdentifier ?? "",
                title: "WakyZzz",
                subtitle: "Do the Task!",
                body: "You have agreed to do a task",
                soundType: .basic,
                volume: 1)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
            
            createNotification(data: data, trigger: trigger, actions: [.textFriend, .textFamily, .deferMore, .complete])
        }
    }
    
    private func createNotification(data: NotificationData, trigger: UNNotificationTrigger, actions: [NotificationCreator.NotificationActionType]) {
        
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.subtitle = data.subtitle
        content.body = data.body
        content.sound = creator.getSound(type: data.soundType, volume: data.volume)
        content.categoryIdentifier = data.categoryIdentifier
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: data.notificationIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let category = UNNotificationCategory(
            identifier: data.categoryIdentifier,
            actions: creator.getActions(types: actions),
            intentIdentifiers: [],
            options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    private func sendSMS(toFamily: Bool) {
        
        let positiveQuotes = [
            "You're off to great places, today is your day",
            "You always pass failure on the way",
            "No one is perfect - that's why pencils have erasers",
            "Winning doesn't always mean being first",
            "You're braver than you believe, and stronger than you seem, and smarter than you think",
            "It always seems impossible until it",
        ]
        let text = toFamily ? positiveQuotes.randomElement() ?? "" : "Hello, what's up?"
        
        //open sms with body filled
        let sms = "sms:?&body=\(text)"
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
    }
    
    private func deleteNotification(id: String) {

        //if delete action remove all notifications with same ID
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
}

// MARK: - UNUserNotificationCenterDelegate Methods

extension NManager: UNUserNotificationCenterDelegate {
    
    
    
    // Fired when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //if app open disable onetime alarm and update table
        // Remove last digit as it is only for the weekDay
        disableOneTimeAlarm(id: String(notification.request.identifier.dropLast()))

        //fetch updated alarm data for table
        delegate?.refreshDataTable()
        completionHandler([.alert, .sound])
    }
    
    // code only runs if user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let state = UIApplication.shared.applicationState

        //if app inactive disable if onetimealarm ?? BACKGROUND
        if state == .background || state == .inactive {
            disableOneTimeAlarm(id: String(response.notification.request.identifier.dropLast()))
            //fetch updated alarm data for table
            delegate?.refreshDataTable()
        }
        
        if let actionIdentifierEnum = NotificationCreator.NotificationActionType(rawValue: response.actionIdentifier) {
            let categoryId = response.notification.request.content.categoryIdentifier
            
            switch actionIdentifierEnum {
            case .snooze:
                scheduleNotification(ofType: .snooze(count: 1), categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .secondSnooze:
                scheduleNotification(ofType: .snooze(count: 2), categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .textFriend:
                sendSMS(toFamily: false)
            case .textFamily:
                sendSMS(toFamily: true)
            case .delete:
                deleteNotification(id: response.notification.request.identifier)
            case .deferMore:
                scheduleNotification(ofType: .deferMore, categoryIdentifier: categoryId, contentIdentifier: response.actionIdentifier)
            case .complete:
                deleteNotification(id: response.notification.request.identifier)
            }
        }
        completionHandler()
    }
}
