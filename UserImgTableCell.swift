//
//  UserImgTableCell.swift
//  AccuraSDK


import UIKit

class UserImgTableCell: UITableViewCell {

    @IBOutlet weak var user_img: UIImageView!
    @IBOutlet weak var User_img2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
