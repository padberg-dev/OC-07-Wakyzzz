//
//  EditAlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

class EditAlarmViewController: UIViewController {

    // MARK: - @IBOutlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Public Parameters
    
    public var delegate: AlarmViewControllerDelegate?
    public var alarm: Alarm?    
    
    // MARK: - VC Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    // MARK: - Private Custom Methods
    
    private func config() {        
        if alarm == nil {
            navigationItem.title = "New Alarm"
            alarm = Alarm()
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
        tableView.delegate = self
        tableView.dataSource = self
        datePicker.date = (alarm?.alarmDate)!
    }
    
    // MARK: - @IBAction Methods
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.alarmViewControllerDone(alarm: alarm!)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setTime(date: datePicker.date)
    }
}

// MARK: - UITableViewDelegate Methods

extension EditAlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
}

// MARK: - UITableViewDataSource Methods

extension EditAlarmViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row]
        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        if (alarm?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
}
