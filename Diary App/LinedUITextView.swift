//
//  LinedUITextView.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 19.10.2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

@IBDesignable
class LinedUITextView: UITextView {

    @IBInspectable var lineWidth: CGFloat = 2
    @IBInspectable var lineColor: UIColor = UIColor.lightGray
    @IBInspectable var lineSpacing: CGFloat = 5
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let fontSize = self.font?.pointSize{
            let numberOfLines = (Int(floor(self.bounds.height / lineSpacing)))

            for i in 1...numberOfLines {
                let path = UIBezierPath()
                let iCGFloat = CGFloat(i)
                let y = ((fontSize + lineSpacing) * iCGFloat) + 1
                path.lineWidth = lineWidth
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: self.bounds.size.width, y: y))
                path.close()
                
                lineColor.set()
                path.stroke()
                path.fill()
            }
        }
    }


}
