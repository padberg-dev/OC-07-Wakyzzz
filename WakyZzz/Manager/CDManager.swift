//
//  CDManager.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 05/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData

class CDManager {
    
    static let shared = CDManager()
    
    // MARK:- Public Methods
    
    public func loadAllAlarms() -> [CDAlarm] {
        
        let fetchRequest: NSFetchRequest<CDAlarm> = CDAlarm.fetchRequest()
        
        var matchArray: [CDAlarm] = []
        do {
            matchArray = try AppDelegate.context.fetch(fetchRequest)
        } catch {
            print("DATABASE ERROR")
        }
        return matchArray
    }
    
    public func addOrUpdateAlarm(_ alarm: Alarm) {
        
        let context = AppDelegate.context
        
        if let existingAlarm = getAlarmWith(id: alarm.id, in: context) {
            existingAlarm.updateWith(alarm: alarm)
        } else {
            let newAlarm = CDAlarm(context: context)
            newAlarm.updateWith(alarm: alarm)
        }
        try! context.save()
    }
    
    public func removeAlarm(withId id: String) {
        
        let context = AppDelegate.context
        
        if let alarm = getAlarmWith(id: id, in: context) {
            context.delete(alarm)
            try! context.save()
        }
    }
    
    public func removeAllAlarms() {
        
        let fetchRequest: NSFetchRequest<CDAlarm> = CDAlarm.fetchRequest()
        
        var matchArray: [CDAlarm] = []
        do {
            matchArray = try AppDelegate.context.fetch(fetchRequest)
            matchArray.forEach { AppDelegate.context.delete($0) }
        } catch {
            print("DATABASE ERROR")
        }
    }
    
    // MARK:- Private Methods
    
    public func getAllAlarmWith(id: String, in context: NSManagedObjectContext) -> [CDAlarm] {
        
        let fetchRequest: NSFetchRequest<CDAlarm> = CDAlarm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        var match: [CDAlarm] = []
        do {
            match = try context.fetch(fetchRequest)
        } catch {
            print("DATABASE ERROR")
        }
        return match
    }
    
    public func getAlarmWith(id: String, in context: NSManagedObjectContext) -> CDAlarm? {
        
        let fetchRequest: NSFetchRequest<CDAlarm> = CDAlarm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let match = try context.fetch(fetchRequest)
            return match.first
        } catch {
            print("DATABASE ERROR")
        }
        return nil
    }
}
