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
    
    func testSavingAndRemovingAlarmsNotificationAndCoreData() {
        
        let alarm = Alarm()
        alarm.time = 28800
        alarm.enabled = true
        alarm.repeatDays = [false, false, false, false, false, false, false]
        // Is this alarm oneTime Alarm?
        
        XCTAssertEqual(alarm.repeating, "One time alarm", "It should be One Time Alarm")
        
        cdManager.addOrUpdateAlarm(alarm)
        nManager.addAlarmNotification(alarm)
        
        // It should not add any new alarm only refresh old one
        nManager.updateAlarmNotification(alarm: alarm)
        
        let expN = expectation(description: "Add Notification")
        nManager.notificationCenter.getPendingNotificationRequests { (notifications) in
            
            XCTAssertEqual(notifications.count, 1, "There should be 1 local notifications set")
            expN.fulfill()
        }
        waitForExpectations(timeout: 3)
        
        let alarmsReceived = cdManager.loadAllAlarms()
        XCTAssert(alarmsReceived.count == 1, "No alarm in Databse")
        
        let exp = expectation(description: "Remove local notifications")
        nManager.removeAlarmNotification(withId: alarm.id)
        nManager.deleteNotification(id: alarm.id)
        center.removeAllPendingNotificationRequests()
        center.getPendingNotificationRequests { (notifications) in
            
            XCTAssertEqual(notifications.count, 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 3)
        
        cdManager.removeAllAlarms()
        center.removeAllPendingNotificationRequests()
        XCTAssertEqual(cdManager.loadAllAlarms().count, 0)
    }
    
    func testDisablingOneTimeAlarm() {
        
        let alarm = Alarm()
        alarm.enabled = true
        
        cdManager.addOrUpdateAlarm(alarm)
        
        XCTAssert(cdManager.loadAllAlarms().count == 1, "There should only be 1 alarm")
        
        nManager.disableOneTimeAlarm(id: alarm.id)
        
        XCTAssert(cdManager.loadAllAlarms()[0].enabled == false, "Alarm should be set to false")
    }
    
    // Add 2 alarms into VC, change second one's time attribute to be less then first ones, sortAlarms, check if they switched places in the array
    func testAlarmsViewController() {
        let alarm1 = Alarm()
        alarm1.time = 28000
        
        let alarm2 = Alarm()
        alarm2.time = 32000
        
        let navigator = UINavigationController(rootViewController: AlarmsViewController())
        let alarmsVC = navigator.topViewController as! AlarmsViewController
        alarmsVC.presentAlarmViewController(alarm: nil)
        alarmsVC.alarms = [alarm1, alarm2]
        
        XCTAssert(alarmsVC.alarms.count == 2, "There should be 2 alarms")
        
        alarm2.time = 18000
        alarmsVC.sortAlarms()
        
        XCTAssert(alarmsVC.alarms[0].time == 18000, "The time of the first alarm should be 18000 now")
    }
    
    // Check if the initializer works
    func testAction() {
        
        let action = Action(caption: "Test caption")
        
        XCTAssert(action.caption == "Test caption", "The aciton should be 'Test caption'")
    }
    
    func testSearchingAndDeletingSpecificAlarm() {
        
        let alarm = Alarm()
        let id = alarm.id
        
        cdManager.addOrUpdateAlarm(alarm)
        
        XCTAssert(cdManager.loadAllAlarms().count == 1, "There should be one object in CoreData")
        let context = AppDelegate.context
        XCTAssert(cdManager.getAlarmWith(id: id, in: context) != nil, "An alarm with this exact id should be returned")
        
        XCTAssert(cdManager.getAllAlarmWith(id: id, in: context).count == 1, "One alarm object with this exact id should be returned")
        
        cdManager.removeAlarm(withId: id)
        
        XCTAssert(cdManager.loadAllAlarms().count == 0, "There should not be any alarm in CoreData")
        
        nManager.removeAlarmNotification(withId: id)
    }
    
    func testTransformingAlarms() {
        
        let alarm = Alarm()
        alarm.time = 12345
        
        cdManager.addOrUpdateAlarm(alarm)
        
        let alarmsArray = cdManager.loadAllAlarms()
        XCTAssert(alarmsArray.count == 1, "There should only be one alarm in CoreData")
        
        let cdAlarm = alarmsArray[0]
        let newlyCreatedAlarm = cdAlarm.transformToAlarm()
        
        XCTAssert(newlyCreatedAlarm.time == 12345, "Those 2 alarms should have the same time")
        
        XCTAssert(newlyCreatedAlarm.id == alarm.id, "Those 2 alarms should have the same id")
    }
    
    func testSettingTimeInAlarm() {
        
        let alarm = Alarm()
        // Time with 0 interval since 1970 is 1AM
        alarm.setTime(date: Date(timeIntervalSince1970: 8 * 3600))
        
        XCTAssert(alarm.time == 9 * 3600, "The time should be 9AM / 9 * 3600s")
    }
    
    func testUpdatingNotification() {
        
        let alarm = Alarm()
        nManager.updateAlarmNotification(alarm: alarm)
    }
    
    func testEditAlarmViewController() {
        
        let navigator = UINavigationController(rootViewController: EditAlarmViewController())
        let alarmsEVC = navigator.topViewController as! EditAlarmViewController
        alarmsEVC.alarm = Alarm()
        let tableView = UITableView()
        let datePicker = UIDatePicker()
        alarmsEVC.tableView = tableView
        alarmsEVC.datePicker = datePicker
        alarmsEVC.viewDidLoad()
        
        XCTAssert(alarmsEVC.navigationItem.title == "Edit Alarm", "Title should be 'Edit Alarm'")
        // It is 1 AM
        datePicker.date = Date(timeIntervalSince1970: 0)
        alarmsEVC.datePickerValueChanged(UIDatePicker())
        
        XCTAssert(alarmsEVC.alarm?.time == 3600, "The time should be 3600s now / 1 AM")
    }
}
