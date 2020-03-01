//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 28/11/2019.
//  Copyright © 2019 Philipp Muellauer. All rights reserved.

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categorys = [Category]()
    var reminders = [Reminder]()
    var categories: Results<Category>?
    let dateFormatter = DateFormatter()
    let locale = NSLocale.current
    // Potential namespace clash with OpaquePointer (same name of Category)
    // Use correct type from dropdown or add backticks to fix e.g., var categories = [`Category`]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        //tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        // load saved reminders, if any
        
        
        if let savedReminders = loadReminders() {
            reminders += savedReminders
        }
        
        loadCategories()
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    
    //Mark: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //let category = categorys[indexPath.row]
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        //print(category.name as Any)
        
        if let time = categories?[indexPath.row].time{
            cell.detailTextLabel?.text = "Due \(dateFormatter.string(from: time))"
        }
        
        
        if let category = categories?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.colour!) else {fatalError()}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
    //Mark: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        let toRemove =  reminders.remove(at: indexPath.row)
        UIApplication.shared.cancelLocalNotification(toRemove.notification)
        //UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: <#T##[String]#>)
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    
    //    //Mark: - Data Manipulation Methods
    func save(_ category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func saveReminders() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(reminders, toFile: Reminder.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save reminders...")
        }
    }
    
        
    func loadReminders() -> [Reminder]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Reminder.ArchiveURL.path) as? [Reminder]
    }
    
    
    //Mark: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //seletedIndex = indexPath.row
        //performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory =  categories?[indexPath.row]
            }
        }
    }
    
    // When returning from AddReminderViewController
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toSettings", sender: nil)
        
    }
    @IBAction func unwindToReminderList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddReminderViewController, let reminder = sourceViewController.newCategory, let localReminder = sourceViewController.reminder {
            // add a new reminder
            reminders.append(localReminder)
            save(reminder)
            saveReminders()
            
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindToList(sender: UIStoryboardSegue) {
        
    }
    
    
}



extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}
