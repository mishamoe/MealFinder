//
//  MealTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 28.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class MealTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    var appDelegate: AppDelegate!
    var menu: Menu!
    var meal: Meal!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sectionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Handle text field's user input through delegate's callback.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Menu.
        if let meal = self.meal {
            nameTextField.text = meal.name
            sectionTextField.text = meal.section
            priceTextField.text = String(meal.price!)
            weightTextField.text = String(meal.weight!)
            
            navigationItem.title = meal.name
        }
        
        // Enable the Save button only if the text field has a valid Menu name.
//        checkValidMenuName()
        
        
    }
    
    // MARK: - Actions

    @IBAction func cancel(sender: AnyObject) {
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sender === saveButton {
            if meal == nil {
                meal = (NSEntityDescription.insertNewObjectForEntityForName("Meal", inManagedObjectContext: self.appDelegate.managedObjectContext) as! Meal)
                meal.menu = menu
            }
            
            meal.name = nameTextField.text
            meal.section = sectionTextField.text
            meal.price = NSNumber(float: Float(priceTextField.text!)!)
            meal.weight = NSNumber(float: Float(weightTextField.text!)!)
            
            appDelegate.saveContext()
        }
    }

}
