//
//  AlarmViewControllerDelegate.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 07/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation

protocol AlarmViewControllerDelegate {
    func alarmViewControllerDone(alarm: Alarm)
    func alarmViewControllerCancel()
}
