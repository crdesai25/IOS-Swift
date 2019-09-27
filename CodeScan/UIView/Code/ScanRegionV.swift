//
//  ScanRegion.swift
//  CodeScan


import UIKit

class ScanRegionV: UIView {

    //MARK:- UIView Methods
    class func nib() -> ScanRegionV {
        return UINib(nibName: "ScanRegionV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ScanRegionV
    }

}
