//
//  NSDate+Extension.swift
//  Voler
//
//  Created by Manoj on 09/09/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import Foundation

let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

extension Date {
    
    // MARK:- ---> Components
    
    fileprivate static func componentFlags() -> NSCalendar.Unit { return [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.weekOfYear] }
    
    fileprivate static func components(fromDate: Date) -> DateComponents! {
        return (Calendar.current as NSCalendar).components(Date.componentFlags(), from: fromDate)
    }
    
    fileprivate func components() -> DateComponents  {
        return Date.components(fromDate: self)!
    }
    
    func getCompoents() -> DateComponents {
        return self.components()
    }
    
    // MARK: Components <---
    
    
    
    // MARK:- ---> Comparing Dates
    
    /**
    Compares dates to see if it's an earlier date.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is earlier.
    */
    func isEarlierThanDate(_ date: Date) -> Bool {
        return (self as NSDate).earlierDate(date) == self
    }
    
    /**
    Compares dates to see if it's a later date.
    
    :param: date :NSDate Date to compare.
    :returns: :Bool Returns true if date is later.
    */
    func isLaterThanDate(_ date: Date) -> Bool {
        return (self as NSDate).laterDate(date) == self
    }
    
    /**
    Checks if date is in future.
    
    :returns: :Bool Returns true if date is in future.
    */
    func isInFuture() -> Bool {
        return self.isLaterThanDate(Date())
    }
    
    /**
    Checks if date is in past.
    
    :returns: :Bool Returns true if date is in past.
    */
    func isInPast() -> Bool {
        return self.isEarlierThanDate(Date())
    }
    
    // MARK: Comparing Dates <---
    
    
    /**
    Returns the year component.
    
    :returns: Int
    */
    func year () -> Int { return self.components().year!  }
    /**
    Returns the month component.
    
    :returns: Int
    */
    func month () -> Int { return self.components().month! }
    
    func hour () -> Int { return self.components().hour! }
    
    // MARK:- ---> Adjusting Dates
    
    /**
    Returns a new NSDate object by a adding years.
    
    :param: days :Int Years to add.
    :returns: NSDate
    */
    func dateByAddingYears(_ years: Int) -> Date {
        var dateComp = DateComponents()
        dateComp.year = years
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a substracting years.
    
    :param: days :Int Years to substract.
    :returns: NSDate
    */
    func dateBySubtractingYears(_ years: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.year = (years * -1)
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a adding days.
    
    :param: days :Int Days to add.
    :returns: NSDate
    */
    func dateByAddingDays(_ days: Int) -> Date {
        var dateComp = DateComponents()
        dateComp.day = days
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    /**
    Returns a new NSDate object by a adding minutes.
    
    :param: days :Int Minutes to add.
    :returns: NSDate
    */
    func dateByAddingMinutes(_ minutes: Int) -> Date {
        var dateComp = DateComponents()
        dateComp.minute = minutes
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func dateByAddingMonths(_ months: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: .month, value: months, to: self, options: [])!
    }
    
    /**
    It will round off to minutes passed and returns new NSDate object
    Related topic is [here](http://stackoverflow.com/questions/6948297/uidatepicker-odd-behavior-when-setting-minuteinterval)
    */
    func dateByRoundingOffCustomInterval(_ minuteInterval: Int) -> (Date) {
        let dateComponents = (Calendar.current as NSCalendar).components(NSCalendar.Unit.minute, from: self)
        let minutes = dateComponents.minute
        
        if minutes == 0 || minutes == minuteInterval {
            return self
        }
        
        //    let minutesF = NSNumber(integer: minutes).floatValue
        //    let minuteIntervalF = NSNumber(integer: minuteInterval).floatValue
        
        // Determine whether to add 0 or the minuteInterval to time found by rounding down
        //    let roundingAmount = (fmodf(minutesF, minuteIntervalF)) > minuteIntervalF/2.0 ? minuteInterval : 0
        
        let roundingAmount = minuteInterval
        let minutesRounded = (minutes! / minuteInterval) * minuteInterval
        let timeInterval = NSNumber(value: (60 * (minutesRounded + roundingAmount - minutes!)) as Int).doubleValue
        let roundedDate = Date(timeInterval: timeInterval, since: self)
        
        return roundedDate.roundSeconds()
    }
    
    func roundSeconds() -> Date{
        
        //Create the date components
        var components = self.components()
        components.second = 0
        
        let roundedDate :Date = Calendar.current.date(from: components)!
        
        return roundedDate
    }
    
    func dateAtTheEndOfMonth() -> Date {
        
        //Create the date components
        var components = self.components()
        //Set the last day of this month
        components.month! += 1
        components.day = 0
        
        //Builds the first day of the month
        let lastDayOfMonth :Date = Calendar.current.date(from: components)!
        
        return lastDayOfMonth
        
    }
    
    func dateAtEndOfDay() -> Date {
        var components = self.components()
        components.hour = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components)!
    }
    
    func dateAtEndOfDayWithHalfAnHourDecrement() -> Date {
        var components = self.components()
        components.hour = 23
        components.minute = 30
        components.second = 0
        return Calendar.current.date(from: components)!
    }
    
    // MARK: Adjusting Dates <---
    
    
    
    // MARK:- ---> To String
    
    // shows 1 or two letter abbreviation for units.
    // does not include 'ago' text ... just {value}{unit-abbreviation}
    // does not include interim summary options such as 'Just now'
    var timeAgoSimple: String {
        
        let now = Date()
        let deltaSeconds = Int(fabs(timeIntervalSince(now)))
        let deltaMinutes = deltaSeconds / 60
        
        var value: Int!
        
        if deltaSeconds < kMinute {
            // Seconds
            return String(format:"%ds", deltaSeconds)
        } else if deltaMinutes < kMinute {
            // Minutes
            return String(format:"%dm",  deltaMinutes)
        } else if deltaMinutes < kDay {
            // Hours
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return String(format:"%dh",  value)
        } else if deltaMinutes < kWeek {
            // Days
            value = Int(floor(Float(deltaMinutes / kDay)))
            return String(format:"%dd",  value)
        } else if deltaMinutes < kMonth {
            // Weeks
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return String(format:"%dw",  value)
        } else if deltaMinutes < kYear {
            // Month
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return String(format:"%dmo",  value)
        }
        
        // Years
        value = Int(floor(Float(deltaMinutes / kYear)))
        return String(format:"%dyr",  value)
    }
    
    var timeAgo: String {
        
        let now = Date()
        let deltaSeconds = Int(fabs(timeIntervalSince(now)))
        let deltaMinutes = deltaSeconds / 60
        
        var value: Int!
        
        if deltaSeconds < 5 {
            // Just Now
            return "Just now"
        } else if deltaSeconds < kMinute {
            // Seconds Ago
            return String(format:"%d seconds ago",  deltaSeconds)
        } else if deltaSeconds < 120 {
            // A Minute Ago
            return "A minute ago"
        } else if deltaMinutes < kMinute {
            // Minutes Ago
            return String(format:"%d minutes ago",  deltaMinutes)
        } else if deltaMinutes < 120 {
            // An Hour Ago
            return "An hour ago"
        } else if deltaMinutes < kDay {
            // Hours Ago
            value = Int(floor(Float(deltaMinutes / kMinute)))
            return String(format:"%d hours ago",  value)
        } else if deltaMinutes < (kDay * 2) {
            // Yesterday
            return "Yesterday"
        } else if deltaMinutes < kWeek {
            // Days Ago
            value = Int(floor(Float(deltaMinutes / kDay)))
            return String(format:"%d days ago",  value)
        } else if deltaMinutes < (kWeek * 2) {
            // Last Week
            return "Last week"
        } else if deltaMinutes < kMonth {
            // Weeks Ago
            value = Int(floor(Float(deltaMinutes / kWeek)))
            return String(format:"%d weeks ago",  value)
        } else if deltaMinutes < (kDay * 61) {
            // Last month
            return "Last month"
        } else if deltaMinutes < kYear {
            // Month Ago
            value = Int(floor(Float(deltaMinutes / kMonth)))
            return String(format:"%d months ago",  value)
        } else if deltaMinutes < (kDay * (kYear * 2)) {
            // Last Year
            return "Last Year"
        }
        
        // Years Ago
        value = Int(floor(Float(deltaMinutes / kYear)))
        return String(format:"%d years ago",  value)
        
    }
    
    func IST() -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        return (formatter.string(from: self))
    }
    
    // MARK: To String <---
    
    
    func offsetFrom(_ date:Date) -> String {
        
        let comp = (Calendar.current as NSCalendar).components([.day, .hour, .minute], from: date, to: self, options: [])
        
        let daysFromDate    = comp.day
        let hoursFromDate   = comp.hour
        let minutesFromDate = comp.minute
        
        var difference:String = ""
        
//        print("daysFromDate--> \(daysFromDate)\nhoursFromDate--> \(hoursFromDate)\nminutesFromDate--> \(minutesFromDate)\n")
        
        if daysFromDate! > 0 {
            difference += "\(daysFromDate) day"
            difference += (daysFromDate! > 1) ? "s ": " "
        }
        
        if (hoursFromDate! > 0 || minutesFromDate! > 0) {
            difference += "\(hoursFromDate)"
            if minutesFromDate! > 0{ difference += ".5" }
            difference += " hour" + ((hoursFromDate == 1 && minutesFromDate == 0) ? "":"s")
        }
        
        return difference
    }
    
    func roundedDaysOffsetFrom(_ date:Date) -> Int {
        
        let comp = (Calendar.current as NSCalendar).components([.day, .hour, .minute], from: date, to: self, options: [])
        
        var daysFromDate    = comp.day
        let hoursFromDate   = comp.hour
        let minutesFromDate = comp.minute
        
        if (hoursFromDate! > 0 || minutesFromDate! > 0) {
            daysFromDate! += 1
        }
        
        return daysFromDate!
    }
    
    
}

// MARK:- ---> Custom

func endDateForThreeMonthsWindow() -> Date {
    var endDate = Date().dateByAddingMonths(2)
    endDate = endDate.dateAtTheEndOfMonth()
    endDate = endDate.dateAtEndOfDayWithHalfAnHourDecrement()
    return endDate
}

// MARK: Custom <---

