//
//  CalendarVC.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

open class CalendarVC: VC, GoogleAPICompatible {
    internal var gIDSignInProxy = GIDSignInProxyObject()
    fileprivate var eventProxy: CoreDataProxy<Day>!
    fileprivate var isLoading = false {
        didSet {
            guard activityIndicator != nil, reloadButton != nil else { return }
            activityIndicator.isHidden = !isLoading
            reloadButton.isHidden = isLoading
            configureFilterButton()
            if isClean {
                if self.generateCalendarSamples().count > 0 { isClean = false }
            }
        }
    }
    fileprivate var topDay: Day?
    
    fileprivate var eventToOpen: (event: Event, rect: CGRect)?
    
    let transition = PopAnimator()
    let interactor = Interactor()
    
    var lastMinOffset: CGFloat?
    var lastBound: PaginationBound?
    var selectedEventCell: EventCell?
    var selectedCalendars: [Calendar]?
    var isClean = false
    
    @IBOutlet weak var overlayButton: OverlayButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        transition.dismissCompletion = { [unowned self] in
            self.selectedEventCell?.backView.isHidden = false
        }
        tableView.register(UINib(nibName: "DayTableViewCell", bundle: bundle), forCellReuseIdentifier: "DayTableViewCell")
        
        gIDSignInProxy.configure(with: self)

        makeProxy()
        
        isLoading = true
        scrollToToday(false)
        activityIndicator.startAnimating()
        RCalendar.main.startForCurrentUser(withOwner: self, calendarListCompletion: { [unowned self] in
            self.configureFilterButton()
        }, completion: { [unowned self] in
            self.isLoading = false
            self.scrollToToday(true)
            self.activityIndicator.stopAnimating()
            }, onError: { [unowned self] in
                self.isLoading = false
                self.activityIndicator.stopAnimating()
        })
        
        overlayButton.configure(text: "today", target: self, selector: #selector(todayButtonAction))
        filterButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        reloadButton.addTarget(self, action: #selector(reloadCurrentBounds), for: .touchUpInside)
        configureFilterButton()
        configureReloadButton()
        configureNotifications()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isClean {
            reloadCurrentBounds()
        }
    }
    
    func configureReloadButton() {
        reloadButton.setImage(UIImage(named: "reload", in: bundle, compatibleWith: nil), for: .normal)
    }
    
    func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(cleanUI), name: NSNotification.Name("rolique-calendar-sign-out"), object: nil)
    }
    
    func reloadCurrentBounds() {
        loadEvents()
    }
    
    func cleanUI() {
        configureFilterButton()
        selectedCalendars = []
        Dealer<Calendar>.clearAllObjects()
        Dealer<Event>.clearAllObjects()
        Dealer<Day>.clearAllObjects()
        CoreData.saveContext {
            self.isClean = true
        }
        makeProxy()
        tableView.reloadData()
    }
    
    func configureFilterButton() {
        filterButton.isEnabled = self.generateCalendarSamples().count > 0 && !isLoading
    }
    
    func makeProxy() {
        eventProxy = CoreDataProxy<Day>()
        
        let eventProxyConfig = ProxyConfigWithTableView(
            tableView: tableView,
            sortDescriptors: [(#keyPath(Day.date), true)],
            filterCalendarIds: selectedCalendars != nil ? selectedCalendars!.map { $0.id ?? "" } : nil,
            updateMode: .tableViewReload,
            proxyConfigTableViewDelegate: self
        ) { [unowned self] (object, indexPath) -> UITableViewCell in
            if let day = object as? Day {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "DayTableViewCell") as! DayTableViewCell
                let filter = self.selectedCalendars != nil ? self.selectedCalendars!.map { $0.id ?? "" } : nil
                cell.update(with: day, delegate: self, filterCalendarIds: filter)
                return cell
            }
            return UITableViewCell()
        }
        eventProxy.configure(config: eventProxyConfig)
    }
    
    func showInfo() {
        let calendars = generateCalendarSamples()
        let rowHeight: CGFloat = 50
        let vc = TableInfoViewController.deploy(with: calendars, selectedCalendars: selectedCalendars) { [unowned self] selectedCalendars in
                self.filter(with: selectedCalendars)
                var title = ""
                switch selectedCalendars.count {
                case calendars.count: title = "All"
                default: title = "\(selectedCalendars.count) of \(calendars.count)"
            }
            self.filterButton.setTitle(title, for: .normal)
        }
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 300, height: rowHeight * CGFloat(calendars.count + 1))
        let popover = vc.popoverPresentationController
        popover?.delegate = self
        popover?.sourceView = filterButton
        popover?.canOverlapSourceViewRect = true
        popover?.permittedArrowDirections = .any
        present(vc, animated: true)
    }
    
    func generateCalendarSamples() -> [Calendar] {
        let calendarIds = RCalendar.main.calendarIds
        
        let calendars = calendarIds.flatMap { Dealer<Calendar>.fetch(with: "id", value: $0) }
        return calendars
    }
    
    func todayButtonAction() {
        scrollToToday(true)
    }
    
    func filter(with calendars: [Calendar]) {
        selectedCalendars = calendars
        makeProxy()
        tableView.reloadData()
        scrollToToday(true)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    fileprivate func scrollToToday(_ animated: Bool) {
        guard let day = findDay(with: Date()), let indexPath = eventProxy.fetchedResultsController?.indexPath(forObject: day) else { return }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
    
    fileprivate func findDay(with date: Date) -> Day? {
        let sectionInfo = eventProxy.fetchedResultsController?.sections?.filter { $0.name == Formatters.monthAndYear.string(from: date) }.first
        let days = sectionInfo?.objects?.filter({ object -> Bool in
            guard let date: Date = (object as? Day)?.date as Date? else { return false }
            let upperBound = date.addingTimeInterval(3600 * 24 * 3).withoutTime
            let lowerBound = date.addingTimeInterval(-3600 * 24 * 3).withoutTime
            let isValidInBoinds = (Date().withoutTime < upperBound) && (Date().withoutTime > lowerBound )
            return (date.withoutTime == Date().withoutTime) || isValidInBoinds
        }).sorted(by: { (day1, day2) -> Bool in
            guard let date1 = ((day1 as? Day)?.date) as Date?, let date2 = ((day2 as? Day)?.date) as Date? else {
                
                return false }
            let interval1 = date1.timeIntervalSince(Date())
            let interval2 = date2.timeIntervalSince(Date())
            let result = abs(interval1) < abs(interval2)

            return result })
        
        return days?.first as? Day
    }
}

fileprivate extension CalendarVC {
    func loadEvents(bound: PaginationBound? = nil, completion: RCalendarCompletion? = nil) {
        if !isLoading {
            activityIndicator.startAnimating()
            isLoading = true
            RCalendar.main.loadEventsForCurrentCalendars(withOwner: self, bound: bound, completion: { [unowned self] in
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                completion?()
                }, onError: { [unowned self] in
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
            })
        }
    }
}

extension CalendarVC: DayTableViewCellDelegate {
    func dayTableViewCelldidSelectEvent(cell: DayTableViewCell, on day: Day?, at indexPath: IndexPath) {
        guard let day = day, let event = day.sortedEvents[safe: indexPath.row] else { return }
        self.selectedEventCell = cell.tableView.cellForRow(at: indexPath) as? EventCell
        let backView = (cell.tableView.cellForRow(at: indexPath) as! EventCell).backView!
        let localRect = cell.tableView.convert(backView.frame, from: backView)
        let rect = cell.tableView.convert(localRect, to: view)
        eventToOpen = (event, rect)
        let vc = EventDetailVC.deploy(with: event)
        vc.transitioningDelegate = self
        vc.interactor = interactor
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true) {}
    }
}

extension CalendarVC: ProxyConfigWithTableViewDelegate {
    func didSelectRow(at indexPath: IndexPath) {
        
    }

    func willUpdate() {
        if lastBound == .min {
            lastMinOffset = tableView.contentSize.height
        }
    }
    
    func didUpdate() {
        guard let lastMinOffset = lastMinOffset, lastBound == .min else { return }
        let diff = tableView.contentSize.height - lastMinOffset
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + diff), animated: false)
    }
    
    func willDisplayFirstRow() {
        loadEvents(bound: .min)
        lastBound = .min
    }
    
    func willDisplayLastRow() {
        loadEvents(bound: .max)
        lastBound = .max
    }
}

extension CalendarVC: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let eventToOpen = eventToOpen else { return nil }

        transition.originFrame = eventToOpen.rect
        transition.presenting = true
        selectedEventCell?.backView.isHidden = true
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}


// MARK: - UIPopoverPresentationControllerDelegate
extension CalendarVC: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
