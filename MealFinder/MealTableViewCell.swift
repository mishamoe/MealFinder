//
//  MealTableViewCell.swift
//  MealFinder
//
//  Created by Михаил on 28.01.16.
//  Copyright © 2016 Михаил. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
