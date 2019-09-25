//
//  CodeInfoV.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/30/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class CodeInfoV: UIView {
    
    //MARK:- Outlet
    @IBOutlet weak var codeLbl: UILabel!
    
    //MARK:- UIView Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 3.0
    }
    
    class func nib() -> CodeInfoV {
        return UINib(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CodeInfoV
    }

}
