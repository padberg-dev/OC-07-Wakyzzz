//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Rafal Padberg on 07/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {

    var cdManager: CDManager!
    var nManager: NManager!
    let center = UNUserNotificationCenter.current()
    
    var alarm: Alarm?
    
    override func setUp() {
        cdManager = CDManager.shared
        nManager = NManager.shared
        
        //remove all saved alarms
        cdManager.removeAllAlarms()
        center.removeAllPendingNotificationRequests()
    }
    
    func testEverything() {
        saveAlarm()
        addedNotifications()
        removeLocalNotification()
        removeAllAlarmData()
    }
    
    func saveAlarm() {
        
        let alarm = Alarm()
        alarm.time = 28800
        alarm.enabled = true
        alarm.repeatDays = [false, false, false, false, false, false, false]
        // Is this alarm oneTime Alarm?
        XCTAssertEqual(alarm.repeating, "One time alarm", "It should be One Time Alarm")
        
        cdManager.addOrUpdateAlarm(alarm)
        nManager.addAlarmNotification(alarm)
    }
    
    func addedNotifications() {
        print ("add notification")
        
        let expN = expectation(description: "Add Notifications")
        center.getPendingNotificationRequests { (notifications) in
            
            XCTAssertEqual(notifications.count, 1, "There should be 1 local notifications set")
            expN.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func removeLocalNotification() {
        
        let exp = expectation(description: "Remove local notifications")
        center.removeAllPendingNotificationRequests()
        center.getPendingNotificationRequests { (notifications) in
            
            XCTAssertEqual(notifications.count, 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func removeAllAlarmData() {
        
        cdManager.removeAllAlarms()
        center.removeAllPendingNotificationRequests()
        XCTAssertEqual(cdManager.loadAllAlarms().count, 0)
    }
}
