//
//  AlarmCellDelegate.swift
//  WakyZzz
//
//  Created by Rafal Padberg on 07/03/2020.
//  Copyright © 2020 Olga Volkova OC. All rights reserved.
//

import Foundation

protocol AlarmCellDelegate {
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool)
}
