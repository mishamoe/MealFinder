//
//  Meal+CoreDataProperties.swift
//  MealFinder
//
//  Created by Михаил on 04.02.16.
//  Copyright © 2016 Михаил. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Meal {

    @NSManaged var name: String?
    @NSManaged var price: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var photo: NSData?
    @NSManaged var ingredients: NSSet?
    @NSManaged var section: Section?

}
