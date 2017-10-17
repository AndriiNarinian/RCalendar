//
//  DroppingModalVC.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/17/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

protocol DroppingModalVCDataSource: class {
    var _scrollView: UIScrollView? { get }
}

class DroppingModalVC: UIViewController {

    var interactor: Interactor?
    
    weak var dataSource: DroppingModalVCDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func configureDroppingModalVC(dataSource: DroppingModalVCDataSource?) {
        interactor?.configure(for: self)
        self.dataSource = dataSource
    }
}


extension DroppingModalVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //interactor?.handleTranslation(scrollView)
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //interactor?.checkIfNeedToDismiss(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            dataSource?._scrollView?.isUserInteractionEnabled = false
        }
    }
    
}
