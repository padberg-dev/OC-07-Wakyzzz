//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit

class AlarmsViewController: UIViewController {
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Parameters
    
    private var alarms = [Alarm]()
    private var editingIndexPath: IndexPath?
    
    // MARK: - VC Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("::: \(self).viewDidLoad()")
        setupDelegates()
        reloadData()
    }
    
    // MARK: - Private Custom Methods
    
    private func setupDelegates() {
        
        tableView.delegate = self
        tableView.dataSource = self
        NManager.shared.delegate = self
    }
    
    private func reloadData() {
        
        let cdAlarms = CDManager.shared.loadAllAlarms()
        alarms = cdAlarms.map { $0.transformToAlarm() }
        sortAlarms()
        alarms.forEach {
            print("::: id: \($0.id)")
            
        }
        tableView.reloadData()
    }
    
    private func sortAlarms() {
        alarms.sort(by: { $0.time < $1.time })
    }
    
    private func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
    private func deleteAlarm(at indexPath: IndexPath) {
        let id = alarms[indexPath.row].id
        
        CDManager.shared.removeAlarm(withId: id)
        NManager.shared.removeAlarmNotification(withId: id)
        
        tableView.beginUpdates()
        alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    private func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    private func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    private func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation Methods
    
    private func presentAlarmViewController(alarm: Alarm?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let editAlarmViewController = popupViewController.viewControllers[0] as! EditAlarmViewController
        editAlarmViewController.alarm = alarm
        editAlarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }
}

// MARK: - AlarmViewControllerDelegate Methods

extension AlarmsViewController: AlarmViewControllerDelegate {
    
    func alarmViewControllerDone(alarm: Alarm) {
        
        CDManager.shared.addOrUpdateAlarm(alarm)
        NManager.shared.updateAlarmNotification(alarm: alarm)
        
        if let editingIndexPath = editingIndexPath {
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            addAlarm(alarm, at: IndexPath(row: alarms.count, section: 0))
        }
        editingIndexPath = nil
        
        sortAlarms()
        tableView.reloadData()
    }
    
    func alarmViewControllerCancel() {
        editingIndexPath = nil
    }
}

// MARK: - AlarmCellDelegate Methods

extension AlarmsViewController: AlarmCellDelegate {
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                alarm.enabled = enabled
                CDManager.shared.addOrUpdateAlarm(alarm)
                NManager.shared.updateAlarmNotification(alarm: alarm)
            }
        }
    }
}

// MARK: - UITableViewDelegate Methods

extension AlarmsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteAlarm(at: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editAlarm(at: indexPath)
        }
        return [delete, edit]
    }
}

// MARK: - UITableViewDataSource Methods

extension AlarmsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
        }
        return cell
    }
}

// MARK: - NManagerDelegate Methods

extension AlarmsViewController: NManagerDelegate {
    
    func refreshDataTable() {
        reloadData()
    }
}

