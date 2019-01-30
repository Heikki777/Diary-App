//
//  DayRatingView.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 24.10.2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

class DayRatingView: UIView {

    var rating: DayRating?{
        didSet{
            self.imageView.image = rating?.image()
        }
    }
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    func setUpView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.white
        
        self.imageView = UIImageView.init()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.imageView)
        
        let imageViewSize = ceil(self.frame.size.height * 0.8)
        
        self.imageView.heightAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        self.imageView.widthAnchor.constraint(equalToConstant: imageViewSize).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.layer.cornerRadius = self.frame.height / 2
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = imageViewSize / 2
        self.imageView.layer.masksToBounds = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
