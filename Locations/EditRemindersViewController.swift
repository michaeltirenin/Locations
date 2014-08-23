//
//  EditRemindersViewController.swift
//  Locations
//
//  Created by Michael Tirenin on 8/20/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import CoreData

class EditRemindersViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

    var context : NSManagedObjectContext!
    var fetchedResultsController : NSFetchedResultsController!
    
//    var reminder : Reminder!
    
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var reminderTitleTextField: UITextField!
    @IBOutlet weak var reminderMessageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Reminder Messages"
        
        self.reminderTitleTextField.delegate = self
        self.reminderMessageTextField.delegate = self

        // get MoC from app delegate
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.context = appDelegate.managedObjectContext
        
        var request = NSFetchRequest(entityName: "Reminder")
        request.returnsObjectsAsFaults = false
        
        var results : NSArray = context.executeFetchRequest(request, error: nil)
        
        if results.count > 0 {
            for res in results {
                println(res)
            }
        } else {
            println("error")
        }
        
//        // get the MOC from app delegate
//        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        self.context = appDelegate.managedObjectContext
//        
//        // setup the fetched results controller
//        var request = NSFetchRequest(entityName: "Reminder")
//        let sort = NSSortDescriptor(key: "reminderTitle", ascending: true)
//        
//        // add sort to the request
//        request.sortDescriptors = [sort]
//        request.fetchBatchSize = 20
//        
//        // initialize the fetched results controller
//        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
//        self.fetchedResultsController.delegate = self
//        
//        // perform fetch on appearance
//        var error : NSError?
//        fetchedResultsController.performFetch(&error)
//        if error != nil {
//            println("error")
//        }
        
//        self.reminderTitleTextField.text = self.fetchedResultsController.fetchedObjects.valueForKey("reminderTitle") as Reminder
//        
//        self.reminderTitleTextField.text = self.fetchedResultsController.fetchedObjects.valueForKey("reminderTitle")
//        self.coordinatesLabel.text = "(" + self.reminder.latitude.stringValue + ", " + self.reminder.longitude.stringValue + ")"
//        self.reminderTitleTextField.text = self.reminder.reminderTitle
//        self.reminderMessageTextField.text = self.reminder.reminderMessage
        
//        self.coordinatesLabel.text = "asdf"
//        self.reminderTitleTextField.text = "aasdfsdf"
//        self.reminderMessageTextField.text = "asdasdfasd"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButton(sender: UIBarButtonItem) {
 
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.context = appDelegate.managedObjectContext

        var editReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.context) as Reminder
        editReminder.reminderTitle = self.reminderTitleTextField.text
        editReminder.reminderMessage = self.reminderMessageTextField.text
        
//        editReminder.setValue(self.reminderTitleTextField.text, forKey: "reminderTitle")
//        editReminder.setValue(self.reminderMessageTextField.text, forKey: "reminderMessage")
        
        var error : NSError?
        self.context.save(&error)
        if error != nil {
            println(error?.localizedDescription)
        }
        
        self.context.save(nil)
        
        println(editReminder)
        
        self.navigationController.popToRootViewControllerAnimated(true)
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // resigns keyboard if any touch happens in white space
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        for control in self.view.subviews {
            if let theControl = control as? UITextField {
                theControl.resignFirstResponder()
            }
        }
    }

}
