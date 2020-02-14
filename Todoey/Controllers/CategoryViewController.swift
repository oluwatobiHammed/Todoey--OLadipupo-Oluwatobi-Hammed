//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 28/11/2019.
//  Copyright © 2019 Philipp Muellauer. All rights reserved.

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
     let realm = try! Realm()
     var categorys = [Category]()
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
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        // load saved reminders, if any
        
        if let savedReminders = loadCategories() {
            categorys += savedReminders
        }

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
        return categorys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let category = categorys[indexPath.row]
        cell.textLabel?.text = category.name
        print(category.name as Any)
        let time = category.time
        cell.detailTextLabel?.text = "Due \(dateFormatter.string(from: time!))"
        
        if let color =  category.colour {
            guard let categoryColour = UIColor(hexString:color) else {fatalError()}
                   cell.backgroundColor = categoryColour
                   cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
                   cell.detailTextLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
              if editingStyle == .delete {
              // Delete the row from the data source
                let toRemove = categorys.remove(at: indexPath.row)
                //UIApplication.shared.cancelLocalNotification(toRemove.notification)
                tableView.deleteRows(at: [indexPath], with: .fade)

          }
    }
    
  
    
    
    
//    //Mark: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                //realm.delete(realm.objects(Categorys.self))
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }



    
    func loadCategories() -> [Category]? {
        return realm.objects(Category.self).toArray(ofType: Category.self) as [Category]
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
            destinationVC.selectedCategory = categorys[indexPath.row]
        }
        }
    }

    // When returning from AddReminderViewController
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toSettings", sender: nil)
        
    }
    @IBAction func unwindToReminderList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddReminderViewController, let reminder = sourceViewController.newCategory {
     // add a new reminder
     let newIndexPath = NSIndexPath(row: categorys.count, section: 0)
     categorys.append(reminder)
     tableView.insertRows(at: [(newIndexPath as IndexPath)], with: .bottom)
     save(category: reminder)
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
