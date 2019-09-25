//
//  DrivingPDFstringTableViewCell.swift
//  AccuraSDK
//
//  Created by SSD on 08/09/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class DrivingPDFstringTableViewCell: UITableViewCell {

    @IBOutlet weak var lblWholerstr: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
