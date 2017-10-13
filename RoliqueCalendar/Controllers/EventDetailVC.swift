//
//  EventDetailVC.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class EventDetailVC: UIViewController {
    class func deploy(with event: Event) -> EventDetailVC {
        let vc = EventDetailVC.instantiateFromStoryboardId(.main)
        vc.event = event
        return vc
    }
    
    @IBOutlet weak var headerBackView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableviewHeightConstraint: NSLayoutConstraint!

    var event: Event!
    var interactor: Interactor?
    
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
        
        tableviewHeightConstraint.constant = (stackView.arrangedSubviews[safe: 5] as? TableEventAttributeView)?.tableViewHeight ?? 0
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        dismiss(animated: true) { }
    }
    
    @IBAction func editButtonAction(sender: UIButton) {
        
    }
}

extension EventDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y <= 0 else { return }
        interactor?.handleTranslation(scrollView.contentOffset)
        //scrollView.contentOffset.y = 0
    }
}

fileprivate extension EventDetailVC {
    func configure() {
        
        interactor?.configure(for: self)
        
        closeButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        titleLabel.text = event.summary
        headerBackView.backgroundColor = headerColor
        configureStackView()
    }
    
    func configureStackView() {
        stackView.arrangedSubviews.forEach { view in
            guard let type = (view as? EventAttributeView)?.type else { return }
            switch type {
            case .time, .location, .reminder, .hangout, .guests, .calendar:
                (view as? BasicEventAttributeView)?.update(with: event)
            case .guestsTable:
                (view as? TableEventAttributeView)?.update(with: event)
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
            default: break
            }
        }
    }
}
