//
//  ViewController.swift
//  DatePicker-iOS
//
//  Created by Suraj Gohil .
//

import UIKit

import Foundation
import UIKit

class ViewController: UIViewController {
    //MARK: - Outlet -
    
    @IBOutlet weak var calendarMenu: CalendarMenu!
    @IBOutlet weak var txtDate: UITextField!
    
    //------------------------------------------------------
    
    //MARK: - Class Variable -
    
    var calendarInterval = CalendarMenu.CalendarInterval.Day
    var dateOfCalendar = Date()
    var firstDayOfCalendar: Date?
    var lastDayOfCalendar: Date?
    var monthOfCalendar = Date()
    var yearOfCalendar = Date()
    
    
    /// Formatter with format: dd MMMM yyyy
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    //------------------------------------------------------
    
    //MARK: - UIView Life Cycle Method -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setupViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //------------------------------------------------------
    
    //MARK: - Memory Management Method -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
    
    //------------------------------------------------------
    
    //MARK: - Custom Method -
    
    private func configCalendarMenu() {
        switch calendarInterval {
        case .Day:
            calendarMenu.dayOfCalendar = dateOfCalendar
            calendarMenu.calendarInterval = .Day
        case .Week:
            calendarMenu.firstDayOfCalendar = firstDayOfCalendar
            calendarMenu.lastDayOfCalendar = lastDayOfCalendar
            calendarMenu.calendarInterval = .Week
        case .Month:
            calendarMenu.monthOfCalendar = monthOfCalendar
            calendarMenu.calendarInterval = .Month
        case .Year:
            calendarMenu.yearOfCalendar = yearOfCalendar
            calendarMenu.calendarInterval = .Year
        }
    }
    
    private func updateCalendar() {
        configCalendarMenu()
        calendarMenu.reloadInputViews()
        calendarMenu.changeDateLabelText()
        txtDate.text = calendarMenu.dateIntervalLabel.text
        switch calendarInterval {
        case .Day:
            dateOfCalendar = calendarMenu.dayOfCalendar ?? Date()
        case .Week:
            firstDayOfCalendar = calendarMenu.firstDayOfCalendar
            lastDayOfCalendar = calendarMenu.lastDayOfCalendar
        case .Month:
            monthOfCalendar = calendarMenu.monthOfCalendar ?? Date().startOfMonth
        case .Year:
            yearOfCalendar = calendarMenu.yearOfCalendar ?? Date()
        }
    }
    
    private func setUpView() {
        self.applyStyle()
    }
    
    private func applyStyle() {
        calendarMenu.style.fontDateInterval = UIFont.systemFont(ofSize: 17.0, weight: .light)
        txtDate.text = dateFormatter.string(from: dateOfCalendar)
        txtDate.delegate = self
        txtDate.addTarget(self, action: #selector(textFieldTapped), for: .touchDown)
        calendarMenu.addTarget(self, action: #selector(cMenuValueChanged), for: .valueChanged)
        
        //If restrict future date selection then set false
        calendarMenu.isSelectFutureDate = true
        calendarMenu.isSelectFutureWeek = true
        calendarMenu.isSelectFutureYear = true
        calendarMenu.isSelectFutureMonth = true
        
        //Hide/show segmentcontroll
        calendarMenu.isSegmentControlHidden = true
    }
    
    @objc func textFieldTapped() {
        configCalendarMenu()
        calendarMenu.showCalendarMenu()
    }
    
    @objc func cMenuValueChanged() {
        calendarInterval = calendarMenu.calendarInterval
        txtDate.text = calendarMenu.dateIntervalLabel.text
        switch calendarInterval {
        case .Day:
            dateOfCalendar = calendarMenu.dayOfCalendar ?? Date()
        case .Week:
            firstDayOfCalendar = calendarMenu.firstDayOfCalendar
            lastDayOfCalendar = calendarMenu.lastDayOfCalendar
        case .Month:
            monthOfCalendar = calendarMenu.monthOfCalendar ?? Date().startOfMonth
        case .Year:
            yearOfCalendar = calendarMenu.yearOfCalendar ?? Date()
        }
    }
    
    /**
     Setup all view model observer and handel data and erros.
     */
    private func setupViewModelObserver() {
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Action Method -
    
    @IBAction func btnPreviousTapped(_ sender: Any) {
        switch calendarInterval {
        case .Day:
            dateOfCalendar = dateOfCalendar.addingTimeInterval(-24 * 60 * 60) // Subtract one day
        case .Week:
            if let firstDay = firstDayOfCalendar, let lastDay = lastDayOfCalendar {
                firstDayOfCalendar = firstDayOfCalendar?.addingTimeInterval(-7 * 24 * 60 * 60) // Subtract one week
                lastDayOfCalendar = lastDayOfCalendar?.addingTimeInterval(-7 * 24 * 60 * 60) // Subtract one week
            } else {
                let firstDay = Date().startOfWeek!
                let lastDay = Date().endOfWeek!
                firstDayOfCalendar = firstDay.addingTimeInterval(-7 * 24 * 60 * 60) // Subtract one week
                lastDayOfCalendar = lastDay.addingTimeInterval(-7 * 24 * 60 * 60) // Subtract one week
            }
        case .Month:
            monthOfCalendar = Calendar.current.date(byAdding: .month, value: -1, to: monthOfCalendar) ?? Date()
        case .Year:
            yearOfCalendar = Calendar.current.date(byAdding: .year, value: -1, to: yearOfCalendar) ?? Date()
        }
        updateCalendar()
    }
    
    @IBAction func btnNextTapped(_ sender: Any) {
        let currentDate = Date()
        
        switch calendarInterval {
        case .Day:
            let nextDay = dateOfCalendar.addingTimeInterval(24 * 60 * 60)
            if calendarMenu.isSelectFutureDate {
                dateOfCalendar = dateOfCalendar.addingTimeInterval(24 * 60 * 60) // Add one day
            } else {
                if nextDay > currentDate {
                    print("Future date selection not allow")
                    return
                } else {
                    dateOfCalendar = dateOfCalendar.addingTimeInterval(24 * 60 * 60) // Add one day
                }
            }
        case .Week:
            let nextWeekStartDate = firstDayOfCalendar?.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
            if calendarMenu.isSelectFutureWeek {
                if let firstDay = firstDayOfCalendar, let lastDay = lastDayOfCalendar {
                    firstDayOfCalendar = firstDayOfCalendar?.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                    lastDayOfCalendar = lastDayOfCalendar?.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                } else {
                    let firstDay = Date().startOfWeek!
                    let lastDay = Date().endOfWeek!
                    firstDayOfCalendar = firstDay.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                    lastDayOfCalendar = lastDay.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                }
            } else {
                if let nextWeekStartDate = nextWeekStartDate, nextWeekStartDate <= currentDate {
                    if let firstDay = firstDayOfCalendar, let lastDay = lastDayOfCalendar {
                        firstDayOfCalendar = firstDayOfCalendar?.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                        lastDayOfCalendar = lastDayOfCalendar?.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                    } else {
                        let firstDay = Date().startOfWeek!
                        let lastDay = Date().endOfWeek!
                        firstDayOfCalendar = firstDay.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                        lastDayOfCalendar = lastDay.addingTimeInterval(7 * 24 * 60 * 60) // Add one week
                    }
                } else {
                    print("Future week selection not allow")
                    return
                }
            }
        case .Month:
            let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: monthOfCalendar) ?? Date()
            if self.calendarMenu.isSelectFutureMonth {
                monthOfCalendar = Calendar.current.date(byAdding: .month, value: 1, to: monthOfCalendar) ?? Date()
            } else {
                if nextMonthDate <= currentDate {
                    monthOfCalendar = nextMonthDate
                } else {
                    print("Future month selection not allow")
                    return
                }
            }
        case .Year:
            let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: yearOfCalendar) ?? Date()
            if self.calendarMenu.isSelectFutureYear {
                yearOfCalendar = Calendar.current.date(byAdding: .year, value: 1, to: yearOfCalendar) ?? Date()
            } else {
                if nextYearDate <= currentDate {
                    yearOfCalendar = nextYearDate
                } else {
                    print("Future year selection not allow")
                    return
                }
            }
        }
        updateCalendar()
    }
    
    //------------------------------------------------------
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtDate {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

