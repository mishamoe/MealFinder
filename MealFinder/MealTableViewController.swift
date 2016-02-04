//
//  MealTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 28.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class MealTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    
    var appDelegate: AppDelegate!
    var meal: Meal!
    var menu: Menu!
    var section: Section?
    var ingredients: NSMutableSet!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sectionTableViewCell: UITableViewCell!
    @IBOutlet weak var ingredientsTableViewCell: UITableViewCell!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Handle text field's user input through delegate's callback.
        nameTextField.delegate = self
        priceTextField.delegate = self
        weightTextField.delegate = self
        
        // Change keyboard type for number values
        priceTextField.keyboardType = .NumbersAndPunctuation
        weightTextField.keyboardType = .NumbersAndPunctuation
        
        // Set up views if editing an existing Menu.
        if let meal = self.meal {
            self.section = meal.section
            self.ingredients = NSMutableSet(set: meal.ingredients!)
            navigationItem.title = meal.name
            
            nameTextField.text = meal.name
            priceTextField.text = String(meal.price!)
            weightTextField.text = String(meal.weight!)
            
            photoImageView.image = meal.getPhotoImage()
        }
        else {
            ingredients = NSMutableSet()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let section = self.section {
            sectionTableViewCell.textLabel?.text = section.name
        }
        
        ingredientsTableViewCell.textLabel?.text = getIngredients()
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
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMeal(sender: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if sender === saveButton {
            guard let name = nameTextField.text where name.characters.count > 0 else {
                return false
            }
            
            guard let section = self.section where section.name!.characters.count > 0 else {
                return false
            }
            
            guard let price = priceTextField.text where (Float(price) != nil) else{
                return false
            }
            
            guard let weight = weightTextField.text where (Float(weight) != nil) else{
                return false
            }
        }
        
        return true
    }
    
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
            meal.ingredients = ingredients
            meal.price = NSNumber(float: Float(priceTextField.text!)!)
            meal.weight = NSNumber(float: Float(weightTextField.text!)!)
            meal.setPhotoFromImage(photoImageView.image!)
            
            appDelegate.saveContext()
        }
        else {
            if segue.identifier == "SelectMealSection" {
                let destination = segue.destinationViewController as! SectionTableViewController
                destination.menu = menu
                destination.section = section
                
                // Hide keyboard.
                nameTextField.resignFirstResponder()
                priceTextField.resignFirstResponder()
                weightTextField.resignFirstResponder()
                
                print("SelectMealSection segue")
            }
            else if segue.identifier == "SelectMealIngredients" {
                let destination = segue.destinationViewController as! IngredientsTableViewController
                destination.ingredients = ingredients
                
                // Hide keyboard.
                nameTextField.resignFirstResponder()
                priceTextField.resignFirstResponder()
                weightTextField.resignFirstResponder()
                
                print("SelectMealSection segue")
            }
        }
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            performSegueWithIdentifier("SelectMealSection", sender: nil)
        }
        else if textField == self.priceTextField {
            weightTextField.becomeFirstResponder()
        }
        else if textField == self.weightTextField {
            // Hide keyboard.
            weightTextField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Methods
    
    func getIngredients() -> String {
        let ingredientsArray = self.ingredients?.allObjects as! [Ingredient]
        
        guard ingredientsArray.count > 0 else {
            return ""
        }
        
        var ingredientsString = ""
        
        for ingredient in ingredientsArray {
            ingredientsString += "\(ingredient.name!), "
        }
        
        let index = ingredientsString.endIndex.advancedBy(-2)
        
        return ingredientsString.substringToIndex(index)
        
    }
}
