//
//  ScanRegion.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/27/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class ScanRegionV: UIView {

    //MARK:- UIView Methods
    class func nib() -> ScanRegionV {
        return UINib(nibName: "ScanRegionV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ScanRegionV
    }

}
