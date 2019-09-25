//
//  SineWaveV.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/27/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

@IBDesignable
class SineWaveView: UIView {
    
    @IBInspectable
    var graphWidth: CGFloat = 1.0  { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var amplitude: CGFloat = 0.20   { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var periods: CGFloat = 1.0      { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
       
        let width = bounds.width
        let height = bounds.height
        let origin = CGPoint(x: width * (1 - graphWidth) / 2, y: height * 0.50)
        let path = UIBezierPath()
        path.lineWidth = 3.0
        path.move(to: origin)
        
        for angle in stride(from: 5.0, through: 360.0 * periods, by: 5.0) {
            
            let x = origin.x + angle / (360.0 * periods) * width * graphWidth
            let y = origin.y - sin(angle / 180.0 * .pi) * height * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        UIColor.indianRed.setStroke()
        path.stroke()
        
        backgroundColor = UIColor.clear
    }
    
}
