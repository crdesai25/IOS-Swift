//
//  DocumentTableCell.swift
//  AccuraSDK
//
//  Created by Deepak Jain on 09/06/19.
//  Copyright © 2019 Elite Development LLC. All rights reserved.
//

import UIKit

class DocumentTableCell: UITableViewCell {
   
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var imgDocument: UIImageView!
    @IBOutlet weak var constraintLblHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
