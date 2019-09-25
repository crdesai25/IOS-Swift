//
//  FirstTableViewCell.swift
//  AccuraSDK
//
//  Created by kuldeep on 8/19/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit

class FirstTableViewCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContect: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
