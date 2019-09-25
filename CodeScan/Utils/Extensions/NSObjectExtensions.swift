//
//  NSObjectExtensions.swift
//  Blueprint
//
//  Created by Stephen Muscarella on 3/24/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//
import Foundation

extension NSObject {
    
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var nameOfClass: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    
}

