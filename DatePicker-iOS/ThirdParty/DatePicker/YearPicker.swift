////
////  YearPicker.swift
////  CalendarMenu
////
////  Created by Suraj Gohil .
////

import UIKit

class YearPicker: UIControl {
    
    var isSelectFutureYear = true
    
    var date: Date = Date() {
        didSet {
            let newValue = calendar.startOfDay(for: date)
            setDate(newValue, animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    var calendar: Calendar = Calendar.autoupdatingCurrent {
        didSet {
            monthDateFormatter.calendar = calendar
            monthDateFormatter.timeZone = calendar.timeZone
            yearDateFormatter.calendar = calendar
            yearDateFormatter.timeZone = calendar.timeZone
        }
    }
    
    var locale: Locale? {
        didSet {
            calendar.locale = locale
            monthDateFormatter.locale = locale
            yearDateFormatter.locale = locale
        }
    }
    
    // MARK: - private variables
    
    fileprivate lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: self.bounds)
        picker.delegate = self
        picker.dataSource = self
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return picker
    }()
    
    fileprivate lazy var monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }()
    
    fileprivate lazy var yearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("y")
        return formatter
    }()
    
    fileprivate enum Component: Int {
        case month
        case year
    }
    
    // MARK: - Initialisation and configuration
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    private func config() {
        addSubview(pickerView)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        setDate(date, animated: false)
    }
    
    /// Select row in the picker with actual date
    ///
    open func setDate(_ date: Date, animated: Bool) {
        guard let yearRange = calendar.maximumRange(of: .year) else {
            return
        }
        let year = calendar.component(.year, from: date) - yearRange.lowerBound
        pickerView.selectRow(year, inComponent: 0, animated: animated)
    }
}

// MARK: - Extensions

extension YearPicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let yearRange = calendar.maximumRange(of: .year),
              let currentYear = calendar.dateComponents([.year], from: Date()).year else {
            return
        }
        
        let selectedYear = yearRange.lowerBound + pickerView.selectedRow(inComponent: 0)
        
        if selectedYear > currentYear {
            if self.isSelectFutureYear {
                self.date = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
            } else {
                pickerView.selectRow(currentYear - yearRange.lowerBound, inComponent: 0, animated: true)
                self.date = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
            }
        } else {
            self.date = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
        }
    }

}

extension YearPicker: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let range = calendar.maximumRange(of: .year) else {
            return 0
        }
        return range.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let range = calendar.maximumRange(of: .year) else {
            return nil
        }
        let year = range.lowerBound + row
        var dateComponents = DateComponents()
        
        dateComponents.year = year
        guard let date = calendar.date(from: dateComponents) else {
            return nil
        }
        
        return yearDateFormatter.string(from: date)
    }
}
