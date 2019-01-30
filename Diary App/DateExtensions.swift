//
//  DateExtensions.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 20/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import Foundation

extension Date{
    func toDiaryDateFormat() -> String{
        let dateFormatter = DateFormatter.init()
        let ordinalFormatter = NumberFormatter.init()
        ordinalFormatter.numberStyle = .ordinal
        let day = Calendar.current.component(.day, from: self)
        let dayOrdinal = ordinalFormatter.string(from: NSNumber(value: day))!
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: self)
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: self)
        return "\(weekDay) \(dayOrdinal) \(month)"
    }
}
