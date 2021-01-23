//
//  DropDownMenuCell.swift
//  getDoc
//
//  Created by Rohan Jagtap on 2020-12-31.
//  Copyright © 2020 Rohan Jagtap. All rights reserved.
//

import DropDown
import UIKit

class DropDownMenuCell: DropDownCell {

    @IBOutlet var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
