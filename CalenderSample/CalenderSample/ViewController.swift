//
//  ViewController.swift
//  CalenderSample
//
//  Created by Nilesh on 17/01/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var datePickerContainer: UIStackView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var selectDateButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    let months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December" ]
    let kStartDate = "2015 01 01"
    let kEndDate = "2049 12 31"
    var numberOfRows = 6
    let formatter = DateFormatter()
    var myCalendar = Calendar.current
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    var hasStrictBoundaries = true
    let firstDayOfWeek: DaysOfWeek = .sunday
    var monthSize: MonthSize? = nil
    var iii: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerContainer.isHidden = true
        
        //self.calendarView.ibCalendarDataSource = self
        //self.calendarView.ibCalendarDelegate = self
        let swipeGestureL = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeGestureL.direction = .left
        swipeGestureL.delegate = self
        self.calendarView.addGestureRecognizer(swipeGestureL)
        
        let swipeGestureR = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeGestureR.direction = .right
        swipeGestureR.delegate = self
        self.calendarView.addGestureRecognizer(swipeGestureR)
        
        self.calendarView.selectDates([NSDate() as Date])
        self.calendarView.scrollToDate(NSDate() as Date, animateScroll: false)
        self.calendarView.visibleDates({ (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        selectDateButton.isHidden = false
        submitButton.isHidden = false
        datePickerContainer.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        selectDateButton.setTitle(dateFormatter.string(from: datePicker.date), for: .normal)
    }
    
    @IBAction func selectDateAction(_ sender: UIButton) {
        datePickerContainer.isHidden = false
        selectDateButton.isHidden = true
        submitButton.isHidden = true
        
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func next(_ sender: Any) {
        self.calendarView.scrollToSegment(.next) {
            self.calendarView.visibleDates({ (visibleDates: DateSegmentInfo) in
                self.setupViewsOfCalendar(from: visibleDates)
            })
        }
    }
    
    @IBAction func prev(_ sender: Any) {
        self.calendarView.scrollToSegment(.previous) {
            self.calendarView.visibleDates({ (visibleDates: DateSegmentInfo) in
                self.setupViewsOfCalendar(from: visibleDates)
            })
        }
    }
    
    @IBAction func today(_ sender: Any) {
        self.calendarView.selectDates([NSDate() as Date])
        self.calendarView.scrollToDate(NSDate() as Date, animateScroll: true)
        self.calendarView.visibleDates({ (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        })
    }
    
    @IBAction func previousButtonClicked(_ sender: UIButton) {
         self.prev(UIButton())
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
         self.next(UIButton())
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        print (sender.direction)
        if sender.direction == .right {
            self.prev(UIButton())
        } else if sender.direction == .left {
            self.next(UIButton())
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = myCalendar.dateComponents([.month], from: startDate).month!
        let monthName = months[(month-1) % 12]
        let year = myCalendar.component(.year, from: startDate)
        self.monthLabel.text = monthName + " " + String(year)
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            cell.dayLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                if myCalendar.isDateInToday(cellState.date) {
                    cell.dayLabel.textColor = UIColor.red
                } else {
                    cell.dayLabel.textColor = UIColor.black
                }
            } else {
                cell.dayLabel.textColor = UIColor.init(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
            }
        }
    }
    
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CellView else {return }
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  cell.selectedView.frame.size.width / 2
            cell.selectedView.isHidden = false
            if myCalendar.isDateInToday(cellState.date) {
                cell.selectedView.backgroundColor = UIColor.red
            } else {
                cell.selectedView.backgroundColor = UIColor.black
            }
        } else {
            cell.selectedView.isHidden = true
        }
        
        cell.selectedView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(
            withDuration: 0.5,
            delay: 0, usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.1,
            options: UIView.AnimationOptions.beginFromCurrentState,
            animations: {
                cell.selectedView.transform = CGAffineTransform(scaleX: 1, y: 1)
        },
            completion: nil
        )
    }
    
    func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
}

extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = myCalendar.timeZone
        formatter.locale = myCalendar.locale
        
        let startDate = formatter.date(from: kStartDate)!
        let endDate = formatter.date(from: kEndDate)!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: numberOfRows,
                                                 calendar: myCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: firstDayOfWeek,
                                                 hasStrictBoundaries: hasStrictBoundaries)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        
        cell.dayLabel.text = cellState.text
        cell.backgroundColor = UIColor.white
        handleCellConfiguration(cell: cell, cellState: cellState)
        cell.check.isHidden = false
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func scrollDidEndDecelerating(for calendar: JTAppleCalendarView) {
        let visibleDates = calendarView.visibleDates()
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: iii)
    }
}


