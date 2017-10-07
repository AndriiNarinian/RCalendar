//
//  Constants.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

typealias VC = UIViewController

let kEventFetchTimeInterval: TimeInterval = 3600 * 24 * 365 / 4

let defaultMinDate = Date().addingTimeInterval(-kEventFetchTimeInterval).withoutTime
let defaultMaxDate = Date().addingTimeInterval(kEventFetchTimeInterval).withoutTime

