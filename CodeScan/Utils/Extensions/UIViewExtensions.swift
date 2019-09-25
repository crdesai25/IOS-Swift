//
//  UIViewExtensions.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/27/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addDropShadow(radius: CGFloat, color: UIColor?) {
        
        if color != nil {
            self.layer.shadowColor = color!.cgColor
        } else {
            self.layer.shadowColor = UIColor.black.cgColor
        }
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = radius
    }

}
