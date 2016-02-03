//
//  IngridientsTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 03.02.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class IngredientsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    var appDelegate: AppDelegate!
    var fetchedResultsController: NSFetchedResultsController!
    
    var ingredients: NSMutableSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addIngredient")
        
        initializeFetchedResultsController()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let ingredients = self.ingredients where ingredients.allObjects.count > 0 {
            for ingridient in ingredients {
                let indexPath = fetchedResultsController.indexPathForObject(ingridient)!
                // Change accessoryType of selected sections' row to checkmark
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if let parent = parent as? UINavigationController {
            if let mealTableViewController = parent.viewControllers.first as? MealTableViewController {
                mealTableViewController.ingredients = self.ingredients
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IngredientTableViewCell", forIndexPath: indexPath)

        // Configure the cell...
        configureCell(cell, indexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let ingredient = fetchedResultsController.objectAtIndexPath(indexPath) as! Ingredient
        cell.textLabel?.text = ingredient.name
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set accessoryType of selected cell to Checkmark
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        
        // Add selected ingredient to ingredients set.
        let ingredient = fetchedResultsController.objectAtIndexPath(indexPath) as! Ingredient
        self.ingredients.addObject(ingredient)
        
        // Remove current view controler from navigation stack.
//        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // Set accessoryType of selected cell to None
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .None
        
        // Remove deselected ingredient from ingredients set.
        let ingredient = fetchedResultsController.objectAtIndexPath(indexPath) as! Ingredient
        self.ingredients.removeObject(ingredient)
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            self.editIngredient(indexPath)
        }
        editAction.backgroundColor = UIColor.grayColor()
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            self.tableView(self.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, editAction]
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete object from context
            let ingredient = fetchedResultsController.objectAtIndexPath(indexPath) as! Ingredient
            appDelegate.managedObjectContext.deleteObject(ingredient)
            appDelegate.saveContext()
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Segue Back")
    }

    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
            self.configureCell(cell!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    // MARK: - Methods
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Ingredient")
        
        let ingredientNameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [ingredientNameSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController \(error)")
        }
    }
    
    func addIngredient() {
        let alert = UIAlertController(title: "Add Ingredient", message: "Enter name of a new ingredient", preferredStyle: .Alert)
        
        // Text field.
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Sentences
            textField.placeholder = "Ingredient name"
        }
        
        // Actions.
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            
            if textField.text?.characters.count > 0 {
                let ingredient = NSEntityDescription.insertNewObjectForEntityForName("Ingredient", inManagedObjectContext:             self.appDelegate.managedObjectContext) as! Ingredient
                ingredient.name = textField.text
                
                self.appDelegate.saveContext()
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func editIngredient(indexPath: NSIndexPath) {
        let ingredient = fetchedResultsController.objectAtIndexPath(indexPath) as! Ingredient
        
        let alert = UIAlertController(title: "Edit Ingredient", message: "Enter ingredient name", preferredStyle: .Alert)
        
        // Text field.
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Sentences
            textField.placeholder = "Ingredient name"
            textField.text = ingredient.name
            
        }
        
        // Actions.
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            
            if textField.text?.characters.count > 0 {
                ingredient.name = textField.text
                self.appDelegate.saveContext()
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
