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
    var meal: Meal!
    var menu: Menu!
    var section: Section?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sectionTableViewCell: UITableViewCell!
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
            self.section = meal.section
            navigationItem.title = meal.name
            
            nameTextField.text = meal.name
            priceTextField.text = String(meal.price!)
            weightTextField.text = String(meal.weight!)
        }
        
        // Enable the Save button only if the text field has a valid Menu name.
//        checkValidMenuName()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let section = self.section {
            sectionTableViewCell.textLabel?.text = section.name
        }
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
    
    @IBAction func unwindToMeal(sender: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sender === saveButton {
            if meal == nil {
                meal = (NSEntityDescription.insertNewObjectForEntityForName("Meal", inManagedObjectContext: self.appDelegate.managedObjectContext) as! Meal)
            }
            
            meal.name = nameTextField.text
            meal.section = section
            meal.price = NSNumber(float: Float(priceTextField.text!)!)
            meal.weight = NSNumber(float: Float(weightTextField.text!)!)
            
            appDelegate.saveContext()
        } else {
            if segue.identifier == "SelectMealSection" {
                let destination = segue.destinationViewController as! SectionTableViewController
                destination.menu = menu
                destination.section = section
                print("SelectMealSection segue")
            }
        }
    }

}
