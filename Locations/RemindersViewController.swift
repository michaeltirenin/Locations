//
//  RemindersViewController.swift
//  Locations
//
//  Created by Michael Tirenin on 8/20/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import CoreData

class RemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var context : NSManagedObjectContext!
    var fetchedResultsController : NSFetchedResultsController!
    
    var selectedReminder : Reminder?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Reminders List"

        // get the MoC from app delegate
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.context = appDelegate.managedObjectContext
        
        // setup the fetched results controller
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "message", ascending: true)
        
        // add sort to the request
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        // initialize the fetched results controller
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        // perform fetch on appearance
        var error : NSError?
        fetchedResultsController.performFetch(&error)
        if error != nil {
            println("error")
        }
    }
    
    // moved to viewDidLoad
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        // perform fetch on appearance
//        var error : NSError?
//        fetchedResultsController.performFetch(&error)
//        if error != nil {
//            println("error")
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController!.sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    // removes the selected cell (so on <back, original selected cell is no longer selected
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        var reminder = self.fetchedResultsController.fetchedObjects[indexPath.row] as Reminder
        cell.textLabel.text = reminder.message
        cell.detailTextLabel.text = "(" + reminder.latitude.stringValue + ", " + reminder.longitude.stringValue + ")"
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    }
    
    // MARK: NSFetchedResultsControllerDelegate Methods
    
    // called when an object is about to change
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath), forIndexPath: indexPath)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: Tableview Delete Rows
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        // don't need anything here, but need this method for the following to work
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {

        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            if let labelForRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
                self.context.deleteObject(labelForRow)
                self.context.save(nil) // saves
            }
        }
                
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    // MARK: Tableview Reorder
    
    @IBOutlet weak var editReminder: UIBarButtonItem!
    @IBAction func editReminderButton(sender: UIBarButtonItem) {
        
        if self.tableView.editing {
            self.tableView.setEditing(false, animated: true)
            editReminder.title = "Edit"
        } else {
            self.tableView.setEditing(true, animated: true)
            editReminder.title = "Done"
        }
    }
    
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!) {
        var cellToMove = self.fetchedResultsController.fetchedObjects[sourceIndexPath.row] as Reminder
        self.context.deleteObject(cellToMove)
        self.context.insertObject(cellToMove)
        self.context.save(nil)
    }
    
}
