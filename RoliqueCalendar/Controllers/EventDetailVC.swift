//
//  EventDetailVC.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class EventDetailVC: DroppingModalVC {
    class func deploy(with event: Event) -> EventDetailVC {
        let vc = EventDetailVC.instantiateFromStoryboardId(.main)
        vc.event = event
        return vc
    }
    
    @IBOutlet weak var headerBackView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarTableviewHeightConstraint: NSLayoutConstraint!
    
    var event: Event!
    
    var eventTitle: String? {
        return event.summary ?? (event.visibility == "private" ? "private event" : "unknown")
    }
    
    var headerColor: UIColor {
        let calendarColorHex = event.calendars.first?.colorHex
        return calendarColorHex != nil ? UIColor(hexString: calendarColorHex!) : .darkGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableviewHeightConstraint.constant = (stackView.arrangedSubviews[safe: 5] as? GuestTableEventAttributeView)?.tableViewHeight ?? 0
        calendarTableviewHeightConstraint.constant = (stackView.arrangedSubviews[safe: 7] as? CalendarTableEventAttributeView)?.tableViewHeight ?? 0
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        dismiss(animated: true) { }
    }
    
    @IBAction func editButtonAction(sender: UIButton) {
        let editVC = EventEditVC.deploy(with: event)
        editVC.modalTransitionStyle = .flipHorizontal
        present(editVC, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.5 : 0
    }
}

extension EventDetailVC: DroppingModalVCDataSource {
    var _scrollView: UIScrollView? {
        return scrollView
    }
}

fileprivate extension EventDetailVC {
    func configure() {
        
        configureDroppingModalVC(dataSource: self)
        
        closeButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        titleLabel.text = eventTitle
        headerBackView.backgroundColor = headerColor
        configureStackView()
        
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    func configureStackView() {
        stackView.arrangedSubviews.forEach { view in
            guard let type = (view as? EventAttributeView)?.type else { return }
            switch type {
            case .time, .location, .reminder, .hangout, .guests, .calendar:
                (view as? BasicEventAttributeView)?.update(with: event)
            case .guestsTable:
                (view as? GuestTableEventAttributeView)?.update(with: event)
            case .calendarTable:
                (view as? CalendarTableEventAttributeView)?.update(with: event)
            }
            switch type {
            case .time:
                stackView.configureViews(for: [0], isHidden: event.start == nil) {}
            case .location:
                stackView.configureViews(for: [1], isHidden: event.location == nil) {}
            case .reminder:
                stackView.configureViews(for: [2], isHidden: (Unwrap<Reminder>.arrayValueFromSet(event.reminders?.overrides).count == 0)) {}
            case .hangout:
                stackView.configureViews(for: [3], isHidden: event.hangoutLink == nil) {}
            case .guests:
                stackView.configureViews(for: [4], isHidden: event.sortedGuests.count == 0) {}
            case .calendar:
                stackView.configureViews(for: [6], isHidden: event.calendars.count == 0) {}
            default: break
            }
        }
    }
}
