//
//  MenuTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 26.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

    var appDelegate: AppDelegate!
    var menu: Menu!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Handle text field's user input through delegate's callback.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Menu.
        if let menu = self.menu {
            nameTextField.text = menu.name
            navigationItem.title = menu.name
        }
        
        // Enable the Save button only if the text field has a valid Menu name.
        checkValidMenuName()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMenuName() {
        let name = nameTextField.text ?? ""
        saveButton.enabled = !name.isEmpty
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMenuName()
        navigationItem.title = textField.text
    }


    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if sender === saveButton {
            if nameTextField.text?.characters.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentedInAddMenuMode: Bool = presentingViewController is UINavigationController
        
        if isPresentedInAddMenuMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            // Remove current view controler from navigation stack.
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if sender === saveButton {
            if menu == nil {
                menu = (NSEntityDescription.insertNewObjectForEntityForName("Menu", inManagedObjectContext: self.appDelegate.managedObjectContext) as! Menu)
            }
            
            menu.name = nameTextField.text
            appDelegate.saveContext()
        }
    }


}
