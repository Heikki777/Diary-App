//
//  DayRating.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 24.10.2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit

enum DayRating: String{
    case Bad
    case Average
    case Good
    
    func image() -> UIImage{
        switch self {
        case .Bad:
            return #imageLiteral(resourceName: "Bad")
        case .Average:
            return #imageLiteral(resourceName: "Average")
        case .Good:
            return #imageLiteral(resourceName: "Good")
        }
    }
}
