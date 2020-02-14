//
//  AddReminderViewController.swift
//  Todoey
//
//  Created by user on 13/02/2020.
//  Copyright © 2020 Philipp Muellauer. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import UserNotifications

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var newCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set self as delegate for text field
        reminderTextField.delegate = self
        checkName()
        // set now as minimum date for picker
        timePicker.minimumDate = NSDate() as Date
        timePicker.locale = NSLocale.current
    }
    
    func checkName() {
        // Disable the Save button if the text field is empty.
        let text = reminderTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func checkDate() {
         // Disable the Save button if date has passed
         if NSDate().earlierDate(timePicker.date) == timePicker.date {
            saveButton.isEnabled = false
         }
     }
    
    // UITextFieldDelegate
     
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // Hide the keyboard.
         textField.resignFirstResponder()
         return true
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
          // Disable the Save button while editing.
        saveButton.isEnabled = false
      }
    @IBAction func timeChanged(_ sender: UIDatePicker) {
         checkDate()
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sender as AnyObject? === saveButton {
              let name = reminderTextField.text!
              let time = timePicker.date
              let color = UIColor.randomFlat().hexValue()
              let timeInterval = floor(time.timeIntervalSinceReferenceDate/60)*60
              //time = NSDate(timeIntervalSinceReferenceDate: timeInterval) as Date
            
            //let cat = CategoryViewController()
            
         
            
            //print("time",time)
               // build notification
               let notification = UNUserNotificationCenter.current()
               let content = UNMutableNotificationContent()
               content.title = "Reminder"
               content.body = "Don't forget to \(name)!"
               content.sound = .default
               
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
               let request = UNNotificationRequest(identifier: "Reminder", content: content, trigger: trigger)
               notification.add(request) { (error) in
                if error != nil {
                    print("Error = \(error?.localizedDescription ?? "error local notification")")
                }
            }

           newCategory = Category(name: name, colour: color, time: time)
        }
    }
}
