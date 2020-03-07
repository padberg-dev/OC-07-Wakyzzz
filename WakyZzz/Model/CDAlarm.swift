//
//  CDAlarm.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 05/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData

class CDAlarm: NSManagedObject {
    
    // MARK:- Public Methods
    
    public func updateWith(alarm: Alarm) {
        
        self.id = alarm.id
        print("\(self.enabled) - \(alarm.enabled)")
        self.enabled = alarm.enabled
        self.time = Int32(alarm.time)
        self.monday = alarm.repeatDays[1]
        self.tuesday = alarm.repeatDays[2]
        self.wednesday = alarm.repeatDays[3]
        self.thursday = alarm.repeatDays[4]
        self.friday = alarm.repeatDays[5]
        self.saturday = alarm.repeatDays[6]
        self.sunday = alarm.repeatDays[0]
    }
    
    public func transformToAlarm() -> Alarm {
        
        let alarm = Alarm()
        alarm.id = self.id ?? ""
        alarm.enabled = self.enabled
        alarm.time = Int(self.time)
        alarm.repeatDays = [
            self.sunday,
            self.monday,
            self.tuesday,
            self.wednesday,
            self.thursday,
            self.friday,
            self.saturday,
        ]
        return alarm
    }
}
