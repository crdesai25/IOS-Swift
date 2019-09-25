//
//  UIViewControllerExtensions.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/27/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import Foundation
import UIKit

enum Direction: String {
    case north = "north"
    case northEast = "northEast"
    case east = "east"
    case southEast = "southEast"
    case south = "south"
    case southWest = "southWest"
    case west = "west"
    case northWest = "northWest"
    case center = "center"

}

extension UIViewController {
    
    func addBarButton(imageNormal: String, imageHighlighted: String?, action: Selector, side: Direction) {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: action, for: .touchUpInside)
        if side == .center
        {

            button.backgroundColor = UIColor.btnRed
            button.setTitle("   Contact US   ", for: .normal)

        }
        else
        {
            button.setImage(UIImage(named: imageNormal), for: .normal)
        }
        if let img = imageHighlighted {
            button.setImage(UIImage(named: img), for: .highlighted)
        }
        
        var barButton: UIBarButtonItem!
        
        if side == .west {
            
            barButton = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barButton
            
        } else if side == .east {
            
            barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
        }
        else if side == .center
        {
            self.navigationItem.titleView = button
        }
    }

}
