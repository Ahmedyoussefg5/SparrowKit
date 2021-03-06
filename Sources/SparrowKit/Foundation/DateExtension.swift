// The MIT License (MIT)
// Copyright © 2020 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(Foundation)
import Foundation

public extension Date {
    
    var isInFuture: Bool {
        return self > Date()
    }
    
    var isInPast: Bool {
        return self < Date()
    }
    
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    var isInTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var isInWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    var isWorkday: Bool {
        return !Calendar.current.isDateInWeekend(self)
    }
    
    var isInCurrentWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isInCurrentMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    var isInCurrentYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func generateDates(to date: Date, withComponent component: Calendar.Component, unit: Int) -> [Date] {
        var fromDate = self
        var dates = [fromDate]
        while fromDate < date {
            if let newDate = Calendar.current.date(byAdding: component, value: unit, to: fromDate)?.start(of: .day) {
                dates.append(newDate)
                fromDate = newDate
            }
        }
        dates.removeAll(where: { $0 > date })
        return dates
    }
    
    /**
     SparrowKit: Returns the value for one component of a date.
     
     - parameter component: The component to calculate.
     - parameter date: The date to use.
     - returns: The value for the component.
     */
    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
    
    func difference(to date: Date, component: Calendar.Component) -> Int {
        let components = Calendar.current.dateComponents([component], from: self, to: date)
        switch component {
        case .nanosecond:
            return components.nanosecond ?? 0
        case .second:
            return components.second ?? 0
        case .minute:
            return components.minute ?? 0
        case .hour:
            return components.hour ?? 0
        case .day:
            return components.day ?? 0
        case .month:
            return components.month ?? 0
        case .year:
            return components.year ?? 0
        default:
            return 0
        }
    }
    
    func setTime(hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components) ?? self
    }
    
    func adding(_ component: Calendar.Component, value: Int = 1) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
    
    mutating func add(_ component: Calendar.Component, value: Int = 1) {
        if let date = Calendar.current.date(byAdding: component, value: value, to: self) {
            self = date
        }
    }
    
    func previous(_ component: Calendar.Component) -> Date {
        self.adding(component, value: -1)
    }
    
    func next(_ component: Calendar.Component) -> Date {
        self.adding(component)
    }
    
    /**
     SparrowKit: Returns the start of component.
     - Important: If it was not possible to get the end of the component, then self is returned.
     - parameter component: The component you want to get the start of (year, month, day, etc.).
     - returns: The start of component.
     */
    func start(of component: Calendar.Component) -> Date {
        if component == .day {
            return Calendar.current.startOfDay(for: self)
        }
        var components: Set<Calendar.Component> {
            switch component {
            case .second: return [.year, .month, .day, .hour, .minute, .second]
            case .minute: return [.year, .month, .day, .hour, .minute]
            case .hour: return [.year, .month, .day, .hour]
            case .day: return [.year, .month, .day]
            case .weekOfYear, .weekOfMonth: return [.yearForWeekOfYear, .weekOfYear]
            case .month: return [.year, .month]
            case .year: return [.year]
            default: return []
            }
        }
        guard components.isEmpty == false else { return self }
        return Calendar.current.date(from: Calendar.current.dateComponents(components, from: self)) ?? self
    }
    
    /**
     SparrowKit: Returns the end of component.
     - Important: If it was not possible to get the end of the component, then self is returned.
     - parameter component: The component you want to get the end of (year, month, day, etc.).
     - returns: The end of component.
     */
    func end(of component: Calendar.Component) -> Date {
        let date = self.start(of: component)
        var components: DateComponents? {
            switch component {
            case .second:
                var components = DateComponents()
                components.second = 1
                components.nanosecond = -1
                return components
            case .minute:
                var components = DateComponents()
                components.minute = 1
                components.second = -1
                return components
            case .hour:
                var components = DateComponents()
                components.hour = 1
                components.second = -1
                return components
            case .day:
                var components = DateComponents()
                components.day = 1
                components.second = -1
                return components
            case .weekOfYear, .weekOfMonth:
                var components = DateComponents()
                components.weekOfYear = 1
                components.second = -1
                return components
            case .month:
                var components = DateComponents()
                components.month = 1
                components.second = -1
                return components
            case .year:
                var components = DateComponents()
                components.year = 1
                components.second = -1
                return components
            default:
                return nil
            }
        }
        guard let addedComponent = components else { return self }
        return Calendar.current.date(byAdding: addedComponent, to: date) ?? self
    }
    
    //MARK: - Formatting
    
    func formatted(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    func formatted(as format: String = "dd.MM.yyyy HH:mm", localized: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        if localized {
            dateFormatter.setLocalizedDateFormatFromTemplate(format)
        } else {
            dateFormatter.dateFormat = format
        }
        return dateFormatter.string(from: self)
    }
    
    /**
     SparrowKit: Returns time interval in text format.
     
     - parameter date: The date until which the calculation takes place.
     - parameter dateStyle: The style to use when formatting day, month, and year information.
     - parameter timeStyle: The style to use when formatting hour, minute, and second information.
     - returns: The time interval in text format.
     */
    
    func formattedInterval(to date: Date, dateStyle: DateIntervalFormatter.Style, timeStyle: DateIntervalFormatter.Style) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self, to: date)
        
    }
    
    /**
     SparrowKit: Returns age in text format.
     
     - parameter date: The date until which the calculation takes place.
     - parameter components: Set of Components you want to get.
     - returns: The age in text format.
     
     Take a look at this example:
     ````
     
     myBirthday.age(to: Date(), components: [.year, .month]) // 3 Years, 8 months
     ````
     */
    func age(to date: Date, components: Set<Calendar.Component>) -> String {
        let calender = Calendar.current
        let dateComponent = calender.dateComponents(components, from: self, to: date)
        var years = ""; var months = ""; var days = "";
        if let _years = dateComponent.year, _years > 0 {
            years = Calendar.Component.year.formatted(numberOfUnits: _years) ?? ""
        }
        if let _months = dateComponent.month, _months > 0 {
            months = Calendar.Component.month.formatted(numberOfUnits: _months) ?? ""
        }
        if var _days = dateComponent.day {
            _days = _days == 0 ? 1 : _days
            days = Calendar.Component.day.formatted(numberOfUnits: _days) ?? ""
        }
        return "\(years) \(months) \(days)".trim
    }
}
#endif



