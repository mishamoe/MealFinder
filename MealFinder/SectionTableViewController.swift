//
//  MealSectionTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 01.02.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class SectionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var appDelegate: AppDelegate!
    var fetchedResultsController: NSFetchedResultsController!
    
    var menu: Menu!
    var section: Section?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addSection")
        
        initializeFetchedResultsController()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let section = self.section {
            let indexPath = fetchedResultsController.indexPathForObject(section)!
            // Change accessoryType of selected sections' row to checkmark
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SectionTableViewCell", forIndexPath: indexPath)

        // Configure the cell...
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let section = fetchedResultsController.objectAtIndexPath(indexPath) as! Section

        cell.textLabel?.text = section.name
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Set section property of MealTableViewController to selected section entity
        let mealTableViewController = self.navigationController?.viewControllers.first as! MealTableViewController
        self.section = fetchedResultsController.objectAtIndexPath(indexPath) as? Section
        mealTableViewController.section = section
        
        // Remove current view controler from navigation stack.
        navigationController?.popViewControllerAnimated(true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            self.editSection(indexPath)
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
            let section = fetchedResultsController.objectAtIndexPath(indexPath) as! Section
            appDelegate.managedObjectContext.deleteObject(section)
            appDelegate.saveContext()
        }
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
        let request = NSFetchRequest(entityName: "Section")
        
        request.predicate = NSPredicate(format: "menu.name = %@", menu.name!)
        
        let sectionNameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sectionNameSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController \(error)")
        }
    }
    
    func addSection() {
        let alert = UIAlertController(title: "Add Section", message: "Enter name of a new section", preferredStyle: .Alert)
        
        // Text field.
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Sentences
            textField.placeholder = "Section name"
        }
        
        // Actions.
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            
            if textField.text?.characters.count > 0 {
                let section = NSEntityDescription.insertNewObjectForEntityForName("Section", inManagedObjectContext:             self.appDelegate.managedObjectContext) as! Section
                section.name = textField.text
                section.menu = self.menu
                
                self.appDelegate.saveContext()
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func editSection(indexPath: NSIndexPath) {
        let section = fetchedResultsController.objectAtIndexPath(indexPath) as! Section
        
        let alert = UIAlertController(title: "Edit Section", message: "Enter section name", preferredStyle: .Alert)
        
        // Text field.
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Sentences
            textField.placeholder = "Section name"
            textField.text = section.name
            
        }
        
        // Actions.
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            
            if textField.text?.characters.count > 0 {
                section.name = textField.text
                self.appDelegate.saveContext()
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
