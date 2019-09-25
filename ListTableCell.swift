//
//  ListTableCell.swift
//  AccuraSDK
//
//  Created by Zignuts Technolab on 07/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit

class ListTableCell: UITableViewCell {

    @IBOutlet weak var lbl_list_title: UILabel!
    @IBOutlet weak var vw: UIView!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
