//
//  ResultTableCell.swift
//  AccuraSDK
//
//  Created by Deepak Jain on 09/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblSinglevalue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
