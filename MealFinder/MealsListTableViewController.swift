//
//  MealsListTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 28.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class MealsListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    
    var appDelegate: AppDelegate!
    var fetchedResultsController: NSFetchedResultsController!
    var menu: Menu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = menu.name
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        initializeFetchedResultsController()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = self.fetchedResultsController.sections!
        let sectionInfo = sections[section]
        
        return sectionInfo.name
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MealTableViewCell", forIndexPath: indexPath) as! MealTableViewCell

        // Configure the cell...
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }

    func configureCell(cell: MealTableViewCell, indexPath: NSIndexPath) {
        let meal = fetchedResultsController.objectAtIndexPath(indexPath) as! Meal
        
        cell.nameLabel.text = meal.name
        cell.priceLabel.text = "$\(meal.price!)"
        cell.weightLabel.text = "\(meal.weight!) g"
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            // Present MenuTableViewController to edit Meal
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let editMealController = storyboard.instantiateViewControllerWithIdentifier("MealTableViewController") as! MealTableViewController
            editMealController.meal = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Meal
            editMealController.menu = self.menu
            
            let navigationController = UINavigationController(rootViewController: editMealController)
            
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
        editAction.backgroundColor = UIColor.grayColor()
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            self.tableView(self.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, editAction]
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete object from context.
            let meal = fetchedResultsController.objectAtIndexPath(indexPath) as! Meal
            appDelegate.managedObjectContext.deleteObject(meal)
            appDelegate.saveContext()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToMealsList(sender: UIStoryboardSegue) {}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "AddMeal" {
            print("AddMeal")
            let destination = segue.destinationViewController as! UINavigationController
            let viewController = destination.topViewController as! MealTableViewController
            viewController.navigationItem.title = "Add meal"
            viewController.menu = menu
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            self.tableView(self.tableView, titleForHeaderInSection: sectionIndex)
        case .Move:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("delete begin")
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            print("delete end")
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! MealTableViewCell
            self.configureCell(cell, indexPath: indexPath!)
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
        let request = NSFetchRequest(entityName: "Meal")
        
        let sectionSort = NSSortDescriptor(key: "section.name", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sectionSort, nameSort]
        
        request.predicate = NSPredicate(format: "section.menu.name = %@", menu.name!)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: "section.name", cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController \(error)")
        }
    }
}
