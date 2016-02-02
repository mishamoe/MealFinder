//
//  Add+EditTableViewController.swift
//  MealFinder
//
//  Created by Михаил on 26.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit
import CoreData

class MenuListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var appDelegate: AppDelegate!
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        initializeFetchedResultsController()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section] 
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath)
        
        // Configure the cell...
        configureCell(cell, indexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let menu = fetchedResultsController.objectAtIndexPath(indexPath) as! Menu
        
        cell.textLabel?.text = menu.name
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) -> Void in
            // Present MenuTableViewController to edit Menu
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let editMenuController = storyboard.instantiateViewControllerWithIdentifier("MenuTableViewController") as! MenuTableViewController
            editMenuController.menu = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Menu
            
            let navigationController = UINavigationController(rootViewController: editMenuController)

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
            let menu = fetchedResultsController.objectAtIndexPath(indexPath) as! Menu
            appDelegate.managedObjectContext.deleteObject(menu)
            appDelegate.saveContext()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToMenuList(sender: UIStoryboardSegue) {}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddMenu" {
            let destination = segue.destinationViewController as! UINavigationController
            let viewController = destination.topViewController as! MenuTableViewController
            viewController.navigationItem.title = "Add menu"
        }
        else if segue.identifier == "ShowMeals" {
            print("ShowMeals.")
            
            if let selectedMenuCell = sender as? UITableViewCell {
                // Get the cell that generated this segue.
                let indexPath = tableView.indexPathForCell(selectedMenuCell)!
                let selectedMenu = fetchedResultsController.objectAtIndexPath(indexPath) as! Menu
                
                let destination = segue.destinationViewController as! MealsListTableViewController
                destination.menu = selectedMenu
            }
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
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
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
        let request = NSFetchRequest(entityName: "Menu")
        
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController \(error)")
        }
    }
}
