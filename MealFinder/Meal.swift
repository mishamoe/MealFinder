//
//  Meal.swift
//  MealFinder
//
//  Created by Михаил on 01.02.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Meal: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    
    func getPhotoImage() -> UIImage? {
        if let photo = self.photo {
            return UIImage(data: photo)
        }
        
        return nil
    }
    
    func setPhotoFromImage(photoImage: UIImage) {
        // Create NSData from UIImage
        if let imageData = UIImageJPEGRepresentation(photoImage, 1) {
            photo = imageData
        }
        
    }
}
