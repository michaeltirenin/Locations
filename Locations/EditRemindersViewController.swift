//
//  EditRemindersViewController.swift
//  Locations
//
//  Created by Michael Tirenin on 8/20/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import UIKit
import CoreData

class EditRemindersViewController: UIViewController, UITextFieldDelegate {

    var context : NSManagedObjectContext!

    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var reminderTitleTextField: UITextField!
    @IBOutlet weak var reminderMessageTextField: UITextField!

    @IBAction func saveButton(sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Edit Reminder Messages"

        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.context = appDelegate.managedObjectContext

        self.reminderTitleTextField.delegate = self
        self.reminderMessageTextField.delegate = self

        self.coordinatesLabel.text = "testlabel"
        self.reminderTitleTextField.text = "testttitle"
        self.reminderMessageTextField.text = "testmessage"
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
