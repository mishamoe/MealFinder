//
//  Ingredient+CoreDataProperties.swift
//  MealFinder
//
//  Created by Михаил on 02.02.16.
//  Copyright © 2016 Михаил. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Ingredient {

    @NSManaged var name: String?
    @NSManaged var meals: NSSet?

}
