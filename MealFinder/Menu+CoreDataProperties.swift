//
//  Menu+CoreDataProperties.swift
//  MealFinder
//
//  Created by Михаил on 26.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Menu {

    @NSManaged var name: String?
    @NSManaged var meals: NSSet?

}
